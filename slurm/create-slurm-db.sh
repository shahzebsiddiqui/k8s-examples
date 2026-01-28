#!/usr/bin/env bash
#
# Script to create Slurm accounting database (slurm_acct_db) and user
# Follows Slurm official documentation (slurmdbd.conf + accounting.html)
# Tested pattern on Rocky 9 / MariaDB 10.5+
#
# Usage:
#   sudo ./create-slurm-db.sh
#   # or pass password via env (less secure, for automation):
#   MYSQL_ROOT_PASS="your_root_pass" sudo -E ./create-slurm-db.sh
#
# After running:
#   - Update StoragePass in /etc/slurm/slurmdbd.conf with SLURM_DB_PASS
#   - Restart slurmdbd: systemctl restart slurmdbd
#

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# Configuration - CHANGE THESE VALUES
# ──────────────────────────────────────────────────────────────────────────────

# MariaDB/MySQL root password (leave empty → will prompt)
MYSQL_ROOT_PASS="${MYSQL_ROOT_PASS:-}"

# Password for the 'slurm' DB user (must match StoragePass in slurmdbd.conf)
# CHANGE THIS TO A STRONG, UNIQUE PASSWORD
SLURM_DB_PASS="password"

# Database name (standard in Slurm docs)
DB_NAME="slurm_acct_db"

# ──────────────────────────────────────────────────────────────────────────────
# Do NOT change below unless you have a very good reason
# ──────────────────────────────────────────────────────────────────────────────

DB_USER="slurm"
DB_HOST="localhost"

# ──────────────────────────────────────────────────────────────────────────────
# Helper functions
# ──────────────────────────────────────────────────────────────────────────────

mysql_cmd() {
    local args=()
    if [[ -n "${MYSQL_ROOT_PASS:-}" ]]; then
        args+=("-p${MYSQL_ROOT_PASS}")
    else
        args+=("-p")  # will prompt
    fi

    mysql -u root "${args[@]}" "$@"
}

echo_info()  { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
echo_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $*"; }
echo_error() { echo -e "\033[1;31m[ERROR]\033[0m  $*" >&2; exit 1; }

# ──────────────────────────────────────────────────────────────────────────────
# Main logic
# ──────────────────────────────────────────────────────────────────────────────

echo_info "Setting up Slurm accounting database..."

# Test root login
if ! mysql_cmd -e "SELECT 1;" >/dev/null 2>&1; then
    echo_error "Cannot connect to MariaDB/MySQL as root. Check service is running and password is correct."
fi

# Create database if not exists
echo_info "Creating database ${DB_NAME} (if not exists)..."
mysql_cmd <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME}
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;
EOF

# Create user if not exists
echo_info "Creating DB user '${DB_USER}'@'${DB_HOST}' (if not exists)..."
mysql_cmd <<EOF
CREATE USER IF NOT EXISTS '${DB_USER}'@'${DB_HOST}'
    IDENTIFIED BY '${SLURM_DB_PASS}';
EOF

# Grant privileges (idempotent - re-granting is safe)
echo_info "Granting ALL privileges on ${DB_NAME}.* to '${DB_USER}'@'${DB_HOST}'..."
mysql_cmd <<EOF
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'${DB_HOST}';
FLUSH PRIVILEGES;
EOF

# Verification steps
echo_info "Verifying setup..."

# Check database exists
if mysql_cmd -e "USE ${DB_NAME};" >/dev/null 2>&1; then
    echo_success "Database '${DB_NAME}' exists."
else
    echo_error "Database '${DB_NAME}' creation failed."
fi

# Check user can connect
if mysql -u "${DB_USER}" -p"${SLURM_DB_PASS}" -e "SELECT 1;" >/dev/null 2>&1; then
    echo_success "User '${DB_USER}' can connect successfully."
else
    echo_error "User '${DB_USER}' login test failed. Check password or privileges."
fi

echo ""
echo_success "Slurm accounting database setup complete!"
echo ""
echo "NEXT STEPS:"
echo "1. Edit /etc/slurm/slurmdbd.conf (or your path):"
echo "   StoragePass=${SLURM_DB_PASS}"
echo "   # also confirm: StorageUser=slurm  StorageLoc=slurm_acct_db  StorageType=accounting_storage/mysql"
echo ""
echo "2. Secure the config file:"
echo "   chown slurm:slurm /etc/slurm/slurmdbd.conf"
echo "   chmod 600 /etc/slurm/slurmdbd.conf"
echo ""
echo "3. Restart slurmdbd:"
echo "   systemctl restart slurmdbd"
echo "   journalctl -u slurmdbd -n 40 -e   # check for success"
echo ""
echo "4. (After slurmdbd is up) add your cluster if needed:"
echo "   sacctmgr add cluster name=\$(hostname -s)  # or your ClusterName"
echo ""
echo "Done. Good luck with your Slurm cluster!"

