#!/bin/bash
# Script to build Slurm RPMs on Rocky Linux 9 with cgroup v2 support
# Usage: sudo ./build_slurm_rpm.sh [SLURM_VERSION]
# If no version provided, uses the default below.
# Output RPMs will be in /tmp/slurm-rpms/

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────────────────────────────────────

DEFAULT_SLURM_VERSION="25.11.2"
SLURM_VERSION="${1:-$DEFAULT_SLURM_VERSION}"
SLURM_TARBALL="slurm-${SLURM_VERSION}.tar.bz2"
SLURM_URL="https://download.schedmd.com/slurm/${SLURM_TARBALL}"
BUILD_DIR="$HOME/rpmbuild"
OUTPUT_DIR="/tmp/slurm-rpms"
RPMMACROS_FILE="$HOME/.rpmmacros"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ──────────────────────────────────────────────────────────────────────────────
# Preflight checks
# ──────────────────────────────────────────────────────────────────────────────

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Error: This script must be run as root (sudo).${NC}" >&2
    exit 1
fi

if ! grep -qi "rocky linux 9\|rhel.*9\|almalinux 9" /etc/os-release 2>/dev/null; then
    echo -e "${YELLOW}Warning: This script is designed for Rocky Linux 9. Detected OS may differ.${NC}"
fi

echo -e "${GREEN}Building Slurm ${SLURM_VERSION} RPMs on Rocky Linux 9 (cgroup v2)...${NC}"

# ──────────────────────────────────────────────────────────────────────────────
# Step 1: Install dependencies
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${YELLOW}[1/5] Installing build dependencies...${NC}"

dnf install -y epel-release
dnf config-manager --set-enabled crb   # Required: contains most -devel packages
dnf groupinstall -y "Development Tools"
dnf install -y \
    rpm-build rpmdevtools \
    gcc gcc-c++ make autoconf automake libtool \
    munge munge-devel \
    mariadb-devel openssl-devel \
    lua-devel \
    readline-devel \
    perl-ExtUtils-MakeMaker perl-Switch perl-DBI perl-Env \
    perl-File-Temp perl-XML-Simple \
    libevent-devel json-c-devel pam-devel \
    python3-devel ncurses-devel \
    libyaml-devel \
    freeipmi-devel numactl-devel pmix-devel \
    systemd-devel dbus-devel \
    hwloc hwloc-devel \
    libbpf libbpf-devel \
    libbpf libbpf-devel

# ──────────────────────────────────────────────────────────────────────────────
# Step 2: Set up RPM build tree
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${YELLOW}[2/5] Setting up RPM build environment...${NC}"

if [ ! -d "${BUILD_DIR}" ]; then
    rpmdev-setuptree
fi

# Write .rpmmacros — note %_prefix must have leading /
cat > "${RPMMACROS_FILE}" << 'EOF'
%_prefix        /usr
%_sysconfdir    /etc
%_with_numa     1
%_with_lua      /usr
%_with_hwloc    --with-hwloc
%_with_pmix     --with-pmix=/usr
%_topdir        %(echo $HOME)/rpmbuild
EOF

echo "Written ${RPMMACROS_FILE}"

# ──────────────────────────────────────────────────────────────────────────────
# Step 3: Download and verify Slurm source tarball
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${YELLOW}[3/5] Downloading Slurm ${SLURM_VERSION}...${NC}"

cd "${BUILD_DIR}/SOURCES"

if [ ! -f "${SLURM_TARBALL}" ]; then
    curl -fSL -O "${SLURM_URL}"
    echo "Download complete."
else
    echo "Tarball already exists, skipping download."
fi

# Verify tarball is a valid bzip2 archive
if ! bzip2 -t "${SLURM_TARBALL}" &>/dev/null; then
    echo -e "${RED}Error: Downloaded tarball is corrupt or invalid. Removing and re-run.${NC}" >&2
    rm -f "${SLURM_TARBALL}"
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────────────
# Step 4: Build RPMs
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${YELLOW}[4/5] Building Slurm RPMs (this may take several minutes)...${NC}"

rpmbuild -ta "${BUILD_DIR}/SOURCES/${SLURM_TARBALL}"

# ──────────────────────────────────────────────────────────────────────────────
# Step 5: Collect output
# ──────────────────────────────────────────────────────────────────────────────

echo -e "${YELLOW}[5/5] Copying RPMs to ${OUTPUT_DIR}...${NC}"

mkdir -p "${OUTPUT_DIR}"
find "${BUILD_DIR}/RPMS/"  -name "*.rpm"     -exec cp -v {} "${OUTPUT_DIR}/" \;
find "${BUILD_DIR}/SRPMS/" -name "*.src.rpm" -exec cp -v {} "${OUTPUT_DIR}/" \; 2>/dev/null || true

echo ""
echo -e "${GREEN}Build complete! RPMs in ${OUTPUT_DIR}:${NC}"
ls -lh "${OUTPUT_DIR}/"*.rpm 2>/dev/null || echo "No RPMs found — check build output above."
echo ""
echo -e "${GREEN}Key packages to install on the controller node:${NC}"
echo "  slurm-*.rpm slurm-slurmctld-*.rpm slurm-slurmd-*.rpm slurm-slurmdbd-*.rpm"
echo ""
echo -e "${GREEN}Install with:${NC}"
echo "  dnf install -y ${OUTPUT_DIR}/slurm-*.rpm"
echo ""
echo -e "${GREEN}Script finished successfully!${NC}"
