#!/usr/bin/env bash
# Creates Slurm accounting database and DB user in MariaDB.
# Idempotent — safe to re-run.
#
# Usage:
#   sudo ./create-slurm-db.sh
#   SLURM_DB_PASS="mysecretpass" sudo -E ./create-slurm-db.sh
#
# After running:
#   Update StoragePass in /etc/slurm/slurmdbd.conf, then:
#   systemctl restart slurmdbd

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info()    { echo -e "${YELLOW}[INFO]${NC}    $*"; }
echo_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
echo_error()   { echo -e "${RED}[ERROR]${NC}   $*" >&2; exit 1; }

# ──────────────────────────────────────────────────────────────────────────────
# Preflight
# ──────────────────────────────────────────────────────────────────────────────

if [[ $EUID -ne 0 ]]; then
    echo_error "Must be run as root (sudo)."
fi

if ! systemctl is-active --quiet mariadb 2>/dev/null && \
   ! systemctl is-active --quiet mysqld 2>/dev/null; then
    echo_error "MariaDB/MySQL does not appear to be running. Start it first: systemctl start mariadb"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────────────────

DB_NAME="slurm_acct_db"
DB_USER="slurm"
DB_HOST="localhost"

# Password: prefer env var, otherwise prompt securely (never use a plaintext default)
if [[ -n "${SLURM_DB_PASS:-}" ]]; then
    echo_info "Using SLURM_DB_PASS from environment."
else
    read -rsp "Enter NEW password for MariaDB '${DB_USER}' user: " SLURM_DB_PASS
    echo ""
    read -rsp "Confirm password: " SLURM_DB_PASS_CONFIRM
    echo ""
    if [[ "${SLURM_DB_PASS}" != "${SLURM_DB_PASS_CONFIRM}" ]]; then
        echo_error "Passwords do not match."
    fi
fi

if [[ -z "${SLURM_DB_PASS}" ]]; then
    echo_error "SLURM_DB_PASS cannot be empty."
fi

# MariaDB root password (optional — if using unix_socket auth as root, leave blank)
if [[ -n "${MYSQL_ROOT_PASS:-}" ]]; then
    MYSQL_AUTH=(-u root -p"${MYSQL_ROOT_PASS}")
else
    echo_info "No MYSQL_ROOT_PASS set — attempting unix_socket auth (root without password)."
    MYSQL_AUTH=(-u root)
fi

mysql_cmd() {
    mysql "${MYSQL_AUTH[@]}" "$@"
}

# ──────────────────────────────────────────────────────────────────────────────
# Test DB connectivity
# ──────────────────────────────────────────────────────────────────────────────

echo_info "Testing MariaDB root connection..."
if ! mysql_cmd -e "SELECT 1;" &>/dev/null; then
    echo_error "Cannot connect to MariaDB as root. Set MYSQL_ROOT_PASS or ensure unix_socket auth is available."
fi
echo_success "Connected to MariaDB."

# ──────────────────────────────────────────────────────────────────────────────
# Create database
# ──────────────────────────────────────────────────────────────────────────────

echo_info "Creating database '${DB_NAME}' (if not exists)..."
mysql_cmd <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;
EOF

# ──────────────────────────────────────────────────────────────────────────────
# Create user and grant privileges
# ──────────────────────────────────────────────────────────────────────────────

echo_info "Creating DB user '${DB_USER}'@'${DB_HOST}' (if not exists)..."
mysql_cmd <<EOF
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_HOST}'
    IDENTIFIED BY '${SLURM_DB_PASS}';
-- Update password if user already existed
ALTER USER '${DB_USER}'@'${DB_HOST}'
    IDENTIFIED BY '${SLURM_DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'${DB_HOST}';
FLUSH PRIVILEGES;
EOF

# ──────────────────────────────────────────────────────────────────────────────
# Verify
# ──────────────────────────────────────────────────────────────────────────────

echo_info "Verifying database..."
if mysql_cmd -e "USE \`${DB_NAME}\`;" &>/dev/null; then
    echo_success "Database '${DB_NAME}' accessible."
else
    echo_error "Database verification failed."
fi

echo_info "Verifying '${DB_USER}' login..."
if mysql -u "${DB_USER}" -p"${SLURM_DB_PASS}" -h "${DB_HOST}" -e "SELECT 1;" &>/dev/null; then
    echo_success "User '${DB_USER}' can connect successfully."
else
    echo_error "User '${DB_USER}' login failed — check privileges."
fi

# ──────────────────────────────────────────────────────────────────────────────
# Summary
# ──────────────────────────────────────────────────────────────────────────────

echo ""
echo_success "Slurm accounting database setup complete!"
echo ""
echo "NEXT STEPS:"
echo "  1. Update /etc/slurm/slurmdbd.conf:"
echo "       StoragePass=<the password you just set>"
echo "       StorageUser=${DB_USER}"
echo "       StorageLoc=${DB_NAME}"
echo ""
echo "  2. Secure slurmdbd.conf:"
echo "       chown slurm:slurm /etc/slurm/slurmdbd.conf"
echo "       chmod 600 /etc/slurm/slurmdbd.conf"
echo ""
echo "  3. Start slurmdbd:"
echo "       systemctl enable --now slurmdbd"
echo "       journalctl -u slurmdbd -n 40 -f"
echo ""
echo "  4. Register your cluster:"
echo "       sacctmgr add cluster name=\$(hostname -s)"
