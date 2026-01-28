#!/bin/bash

# Script to build Slurm RPMs on Rocky Linux 9 with cgroup v2 support using .rpmmacros
# Run as root (e.g., sudo ./build-slurm-rpms.sh [SLURM_VERSION])
# If no version provided, uses the latest stable (25.11.2 as of Jan 2026)
# Output RPMs will be in /tmp/slurm-rpms/

set -e  # Exit on any error

if [ -z "$1" ]; then
	echo "Usage: $0 <slurm_version> see https://slurm.schedmd.com/download.html"
	exit 1
fi

# Configuration
DEFAULT_SLURM_VERSION="25.11.2"
SLURM_VERSION="${1:-$DEFAULT_SLURM_VERSION}"
SLURM_TARBALL="slurm-${SLURM_VERSION}.tar.bz2"
SLURM_URL="https://download.schedmd.com/slurm/${SLURM_TARBALL}"
BUILD_DIR="$HOME/rpmbuild"  # Use $HOME for non-root friendly, but assuming root
OUTPUT_DIR="/tmp/slurm-rpms"
RPMMACROS_FILE="$HOME/.rpmmacros"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Slurm RPM build on Rocky Linux 9 with cgroup v2 support (version: ${SLURM_VERSION})...${NC}"

# Step 1: Install dependencies
echo -e "${YELLOW}Installing build dependencies...${NC}"
dnf install -y epel-release
dnf config-manager --set-enabled crb   # Critical: contains most -devel packages

dnf groupinstall -y "Development Tools"
dnf install -y rpm-build rpmdevtools gcc gcc-c++ make autoconf automake libtool \
    readline-devel perl-ExtUtils-MakeMaker munge munge-devel \
    mariadb-devel libdb-devel openssl-devel lua-devel \
    readline-devel perl-Switch perl-DBI perl-Env perl-File-Temp \
    perl-XML-Simple libevent-devel json-c-devel pam-devel \
    python3-devel ncurses-devel man2html libyaml-devel \
    freeipmi-devel numactl-devel pmix-devel \
    systemd-devel hwloc hwloc-devel dbus-devel libbpf libbpf-devel  # Added for cgroup v2 

# Step 2: Create RPM build environment if it doesn't exist
if [ ! -d "${BUILD_DIR}" ]; then
    echo -e "${YELLOW}Setting up RPM build environment...${NC}"
    rpmdev-setuptree
fi

cat > $RPMMACROS_FILE << 'EOF'
%_prefix _usr
%_sysconfdir /etc/slurm
%_with_numa 1
%_with_lua /usr
%_with_hwloc --with-hwloc
%_with_pmix --with-pmix=/usr
%_topdir %(echo $HOME)/rpmbuild
EOF

# Step 3: Download Slurm source tarball
echo -e "${YELLOW}Downloading Slurm ${SLURM_VERSION}...${NC}"
cd "${BUILD_DIR}/SOURCES"
if [ ! -f "${SLURM_TARBALL}" ]; then
    curl -O "${SLURM_URL}"
else
    echo "Tarball already exists, skipping download."
fi

# Step 4: Build the RPMs using rpmbuild -ta (handles unpack and spec internally)
echo -e "${YELLOW}Building Slurm RPMs" 
rpmbuild -ta "${SLURM_TARBALL}"

# If you want SRPMs too, add: rpmbuild -ts "${SLURM_TARBALL}"

# Step 5: Copy RPMs to output directory
echo -e "${YELLOW}Copying RPMs to output directory...${NC}"
mkdir -p "${OUTPUT_DIR}"
find "${BUILD_DIR}/RPMS/" -name "*.rpm" -exec cp -v {} "${OUTPUT_DIR}/" \;
find "${BUILD_DIR}/SRPMS/" -name "*.src.rpm" -exec cp -v {} "${OUTPUT_DIR}/" \; 2>/dev/null || true

# List the built RPMs
echo -e "${GREEN}Build complete! RPMs are in ${OUTPUT_DIR}:"
ls -la "${OUTPUT_DIR}/" | grep ".rpm" || echo "No RPMs found (check logs)."
echo -e "${GREEN}Key RPMs include: slurm-*.rpm (server), slurm-devel-*.rpm (dev), slurm-slurmctld-*.rpm (daemon), etc.${NC}"

# Optional: Clean up .rpmmacros change if desired (comment out to keep)
# sed -i '/^%_with_cgroupv2/d' "${RPMMACROS_FILE}"

echo -e "${GREEN}Script finished successfully!${NC}"
