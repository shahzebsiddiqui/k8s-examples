#!/usr/bin/env bash
# Creates the 'slurm' system user/group and required directories.
# Idempotent — safe to re-run.
# Usage: sudo ./create-slurm-user.sh

set -euo pipefail

SLURM_USER="slurm"
SLURM_GROUP="slurm"
SLURM_USERID=9999
SLURM_GID=9999

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ──────────────────────────────────────────────────────────────────────────────
# Preflight
# ──────────────────────────────────────────────────────────────────────────────

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: Must be run as root (sudo).${NC}" >&2
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────────────
# Group
# ──────────────────────────────────────────────────────────────────────────────

if getent group "${SLURM_GROUP}" &>/dev/null; then
    echo -e "${YELLOW}Group '${SLURM_GROUP}' already exists, skipping.${NC}"
else
    groupadd -g "${SLURM_GID}" "${SLURM_GROUP}"
    echo -e "${GREEN}Created group '${SLURM_GROUP}' (gid=${SLURM_GID}).${NC}"
fi

# ──────────────────────────────────────────────────────────────────────────────
# User
# ──────────────────────────────────────────────────────────────────────────────

if id "${SLURM_USER}" &>/dev/null; then
    echo -e "${YELLOW}User '${SLURM_USER}' already exists, skipping.${NC}"
else
    useradd \
        --system \
        --uid "${SLURM_USERID}" \
        --gid "${SLURM_GROUP}" \
        --comment "Slurm workload manager" \
        --home-dir /var/lib/slurm \
        --no-create-home \
        --shell /sbin/nologin \
        "${SLURM_USER}"
    echo -e "${GREEN}Created user '${SLURM_USER}' (uid=${SLURM_USERID}).${NC}"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Directories
# ──────────────────────────────────────────────────────────────────────────────

# Controller directories
DIRS_755=(
    /var/log/slurm
    /var/spool/slurmctld
    /var/spool/slurmd
)

# State/lib directory — tighter permissions
DIRS_700=(
    /var/lib/slurm
)

for dir in "${DIRS_755[@]}"; do
    mkdir -p "${dir}"
    chown "${SLURM_USER}:${SLURM_GROUP}" "${dir}"
    chmod 755 "${dir}"
    echo -e "${GREEN}Directory ${dir} (755)${NC}"
done

for dir in "${DIRS_700[@]}"; do
    mkdir -p "${dir}"
    chown "${SLURM_USER}:${SLURM_GROUP}" "${dir}"
    chmod 700 "${dir}"
    echo -e "${GREEN}Directory ${dir} (700)${NC}"
done

# ──────────────────────────────────────────────────────────────────────────────
# Munge (required for Slurm auth)
# ──────────────────────────────────────────────────────────────────────────────

if ! rpm -q munge &>/dev/null; then
    echo -e "${YELLOW}munge not installed — installing...${NC}"
    dnf install -y munge munge-devel munge-libs
fi

if [ ! -f /etc/munge/munge.key ]; then
    echo -e "${YELLOW}Generating munge key...${NC}"
    /usr/sbin/create-munge-key -r
    chown munge:munge /etc/munge/munge.key
    chmod 400 /etc/munge/munge.key
    echo -e "${GREEN}Munge key generated at /etc/munge/munge.key${NC}"
    echo -e "${YELLOW}IMPORTANT: Copy /etc/munge/munge.key to ALL cluster nodes (same key everywhere).${NC}"
else
    echo -e "${YELLOW}Munge key already exists, skipping generation.${NC}"
fi

systemctl enable --now munge
echo -e "${GREEN}Munge service enabled and started.${NC}"

echo ""
echo -e "${GREEN}Slurm user/group and directories created successfully.${NC}"
echo ""
echo "NEXT STEPS:"
echo "  1. Copy /etc/munge/munge.key to all worker nodes (chmod 400, chown munge:munge)"
echo "  2. Run create-slurm-db.sh to set up accounting DB"
echo "  3. Install Slurm RPMs and place slurm.conf + slurmdbd.conf in /etc/slurm/"
