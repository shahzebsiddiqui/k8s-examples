#!/bin/bash

# Usage: ./build_pmix.sh version
# Example: ./build_pmix.sh 6.0.0

# Check if version argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <pmix_version> see https://github.com/openpmix/openpmix/releases"
    exit 1
fi

PMIX_VERSION=$1

# for some reason having startup modules such as gcc from spack causes build errors with unable to compile C code. Clean environment is required 
module purge

# Prerequisites
sudo yum install -y rpm-build rpmdevtools libevent-devel hwloc-devel zlib-devel python3-devel 

# rpmdev-setuptree will create directories for you its equivalent to running 'mkdir -p $HOME/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}'
rpmdev-setuptree 

BUILD_DIR=$HOME/rpmbuild
# Step 1: Download PMIx SRPM 
cd $BUILD_DIR/SRPMS
# Spec files all come in release -1 
srpm=pmix-${PMIX_VERSION}-1.src.rpm

# remove any srpm that may have been downloaded 
rm -v $srpm
specfile=pmix-${PMIX_VERSION}.spec
sourcefile=pmix-${PMIX_VERSION}.tar.bz2


wget https://github.com/openpmix/openpmix/releases/download/v${PMIX_VERSION}/$srpm
# remove any spec file or tarball that may be downloaded prior to running rpm2cpio
rm -v $specfile
rm -v $sourcefile
wget https://github.com/openpmix/openpmix/releases/download/v${PMIX_VERSION}/$srpm
# extract srpm to get specfile and tarball
rpm2cpio $srpm | cpio -dimv

# move specfile and sourcefile to their respective directories
mv $specfile ../SPECS
mv $sourcefile ../SOURCES
rm $srpm

# Step 2: Build the RPM package
cd $BUILD_DIR
rpmbuild  -ba $BUILD_DIR/SPECS/$specfile

# Step 3: Output location of RPM
RPM_PATH=$(find $BUILD_DIR/RPMS/ -name "pmix*.rpm")
echo "RPM package created at: $RPM_PATH"

rpm -qi $RPM_PATH
# Step 4: Install the RPM (optional)
# Uncomment the following line to automatically install the RPM after building (optional)
# sudo rpm -ivh $RPM_PATH

# End of script

