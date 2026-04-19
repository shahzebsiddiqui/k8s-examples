#!/usr/bin/env bash
# Master setup script for Slurm on Rocky Linux 9
# Orchestrates: user creation → DB setup → config install → service start
#
# Usage (controller node):
#   sudo SLURM_DB_PASS="strongpassword" ./slurm_setup.sh [--controller|--worker]
#
# For workers, only slurmd is needed — pass --worker flag.

set -euo pipefail

ROLE="${1:---controller}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SLURM_CONF_DIR="/etc/slurm"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()     { echo -e "${GREEN}[SETUP]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ──────────────────────────────────────────────────────────────────────────────
# Preflight
# ──────────────────────────────────────────────────────────────────────────────

[[ $EUID -ne 0 ]] && error "Must be run as root."

if ! grep -qi "rocky linux 9" /etc/os-release 2>/dev/null; then
    warn "Not detected as Rocky Linux 9 — proceeding anyway."
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 1: Slurm user + directories
# ──────────────────────────────────────────────────────────────────────────────

log "Step 1: Creating slurm user and directories..."
bash "${SCRIPT_DIR}/create-slurm-user.sh"

# ──────────────────────────────────────────────────────────────────────────────
# Step 2: Database (controller only)
# ──────────────────────────────────────────────────────────────────────────────

if [[ "${ROLE}" == "--controller" ]]; then
    log "Step 2: Setting up accounting database..."

    if ! rpm -q mariadb-server &>/dev/null; then
        log "Installing MariaDB..."
        dnf install -y mariadb-server
        systemctl enable --now mariadb
        log "Running mysql_secure_installation..."
        mysql_secure_installation
    fi

    bash "${SCRIPT_DIR}/create-slurm-db.sh"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 3: Install config files
# ──────────────────────────────────────────────────────────────────────────────

log "Step 3: Installing Slurm config files to ${SLURM_CONF_DIR}..."
mkdir -p "${SLURM_CONF_DIR}"

cp "${SCRIPT_DIR}/slurm.conf"   "${SLURM_CONF_DIR}/slurm.conf"
cp "${SCRIPT_DIR}/cgroup.conf"  "${SLURM_CONF_DIR}/cgroup.conf"

if [[ "${ROLE}" == "--controller" ]]; then
    cp "${SCRIPT_DIR}/slurmdbd.conf" "${SLURM_CONF_DIR}/slurmdbd.conf"
    chown slurm:slurm "${SLURM_CONF_DIR}/slurmdbd.conf"
    chmod 600 "${SLURM_CONF_DIR}/slurmdbd.conf"
fi

chown slurm:slurm "${SLURM_CONF_DIR}/slurm.conf" "${SLURM_CONF_DIR}/cgroup.conf"
chmod 644 "${SLURM_CONF_DIR}/slurm.conf" "${SLURM_CONF_DIR}/cgroup.conf"

log "Config files installed."

# ──────────────────────────────────────────────────────────────────────────────
# Step 4: Enable and start services
# ──────────────────────────────────────────────────────────────────────────────

log "Step 4: Starting Slurm services (role: ${ROLE})..."

if [[ "${ROLE}" == "--controller" ]]; then
    systemctl enable --now slurmdbd
    log "Waiting 5s for slurmdbd to initialize..."
    sleep 5
    systemctl enable --now slurmctld
else
    systemctl enable --now slurmd
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 5: Register cluster (controller only)
# ──────────────────────────────────────────────────────────────────────────────

if [[ "${ROLE}" == "--controller" ]]; then
    log "Step 5: Registering cluster with sacctmgr..."
    CLUSTER_NAME=$(grep '^ClusterName=' "${SLURM_CONF_DIR}/slurm.conf" | cut -d= -f2 | tr -d ' ')
    if [[ -n "${CLUSTER_NAME}" ]]; then
        sacctmgr -i add cluster name="${CLUSTER_NAME}" || warn "Cluster may already be registered."
    else
        warn "Could not determine ClusterName from slurm.conf — register manually with sacctmgr."
    fi
fi

# ──────────────────────────────────────────────────────────────────────────────
# Summary
# ──────────────────────────────────────────────────────────────────────────────

echo ""
log "Slurm setup complete (role: ${ROLE})!"
echo ""
echo "Verify services:"
if [[ "${ROLE}" == "--controller" ]]; then
    echo "  systemctl status slurmdbd slurmctld"
    echo "  sinfo       # should show your partition and nodes"
    echo "  sacctmgr show cluster"
else
    echo "  systemctl status slurmd"
fi
echo ""
echo "Check logs if anything looks off:"
echo "  journalctl -u slurmctld -n 50"
echo "  journalctl -u slurmdbd  -n 50"
echo "  journalctl -u slurmd    -n 50"
