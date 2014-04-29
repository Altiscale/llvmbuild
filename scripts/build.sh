#!/bin/bash

curr_dir=`dirname $0`
curr_dir=`cd $curr_dir; pwd`

llvm_spec="$curr_dir/llvm.spec"


if [ -f "$curr_dir/setup_env.sh" ]; then
  source "$curr_dir/setup_env.sh"
fi

if [ "x${WORKSPACE}" = "x" ] ; then
  WORKSPACE="$curr_dir/../"
fi

if [ ! -e "$llvm_spec" ] ; then
  echo "fail - missing $llvm_spec file, can't continue, exiting"
  exit -9
fi

# Install boost on the fly since we need version 1.42+
# Move this to a RPM and just install it, this takes ~15-20 minutes everytime.

env | sort
# should switch to WORKSPACE, current folder will be in WORKSPACE/llvm due to 
# hadoop_ecosystem_component_build.rb => this script will change directory into your submodule dir
# WORKSPACE is the default path when jenkin launches e.g. /mnt/ebs1/jenkins/workspace/llvm_build_test-alee
# If not, you will be in the $WORKSPACE/llvm folder already, just go ahead and work on the submodule
# The path in the following is all relative, if the parent jenkin config is changed, things may break here.
pushd `pwd`
cd $WORKSPACE

# TBD: we should sanatize the LLVM source folder, so if we re-build it again, it will always be a clean build.
if [ -d "$WORKSPACE/llvm" ] ; then
  echo "ok - deleting folder $WORKSPACE/llvm"
  stat "$WORKSPACE/llvm"
  # rm -rf "$WORKSPACE/llvm"
fi
tar -czf $WORKSPACE/llvm.tar.gz $WORKSPACE/llvm

# Download LLVM from SVN (don't download form tar ball, a bit risky)
echo "ok - source file ready, preparing for build/compile by rpmbuild"

# Looks like this is not installed on all machines
# rpmdev-setuptree
mkdir -p $WORKSPACE/rpmbuild/{BUILD,BUILDROOT,RPMS,SPECS,SOURCES,SRPMS}/
cp "$llvm_spec" $WORKSPACE/rpmbuild/SPECS/llvm.spec
if [ -d $WORKSPACE/rpmbuild/SOURCES/llvm ] ; then
  echo "ok - detected existing SOURCES/llvm from previous rpmbuild, deleting it"
  rm -rf "$WORKSPACE/rpmbuild/SOURCES/llvm"
fi

cp $WORKSPACE/llvm.tar.gz $WORKSPACE/rpmbuild/SOURCES/
#cp $WORKSPACE/patches/* $WORKSPACE/rpmbuild/SOURCES/
# Explicitly define IMPALA_HOME here for build purpose
export LLVM_HOME=$WORKSPACE/rpmbuild/BUILD/llvm
export QA_RPATHS=$[ 0x0001|0x0002|0x0010|0x0008 ]

echo "QA_RPATHS=$QA_RPATHS"

# Override _libdir to /usr/lib, otherwise, it will install under /usr/lib64/
# _prefix should point to /usr/local
rpmbuild -vv -ba $WORKSPACE/rpmbuild/SPECS/llvm.spec \
  --define "_topdir $WORKSPACE/rpmbuild" \
  --define "_libdir /usr/local/lib" \
  --define "_prefix /usr/local" \
  --buildroot $WORKSPACE/rpmbuild/BUILDROOT/

if [ $? -ne "0" ] ; then
  echo "fail - RPM build failed"
  exit -9
fi
  
echo "ok - build Completed successfully!"

exit 0












