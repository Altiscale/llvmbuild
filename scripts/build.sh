#!/bin/bash

curr_dir=`dirname $0`
curr_dir=`cd $curr_dir; pwd`

llvm_spec="$curr_dir/llvm.spec"
mock_cfg="$curr_dir/altiscale-llvm-centos-6-x86_64.cfg"
mock_cfg_name=$(basename "$mock_cfg")
mock_cfg_runtime=`echo $mock_cfg_name | sed "s/.cfg/.runtime.cfg/"`

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
  # echo "ok - deleting folder $WORKSPACE/llvm"
  stat "$WORKSPACE/llvm"
  # rm -rf "$WORKSPACE/llvm"
fi
tar -czf llvm.tar.gz llvm

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
stat $WORKSPACE/rpmbuild/SOURCES/llvm.tar.gz
#cp $WORKSPACE/patches/* $WORKSPACE/rpmbuild/SOURCES/
# Explicitly define IMPALA_HOME here for build purpose

export LLVM_HOME=$WORKSPACE/rpmbuild/BUILD/llvm
export QA_RPATHS=$[ 0x0001|0x0002|0x0010|0x0008 ]

echo "QA_RPATHS=$QA_RPATHS"

# Override _libdir to /usr/lib, otherwise, it will install under /usr/lib64/
# _prefix should point to /usr/local
echo "ok - applying version number $LLVM_VERSION and release number $BUILD_TIME"
sed -i "s/LLVM_VERSION/$LLVM_VERSION/g" "$WORKSPACE/rpmbuild/SPECS/llvm.spec"
sed -i "s/BUILD_TIME/$BUILD_TIME/g" "$WORKSPACE/rpmbuild/SPECS/llvm.spec"
rpmbuild -vvv -bs $WORKSPACE/rpmbuild/SPECS/llvm.spec \
  --define "_topdir $WORKSPACE/rpmbuild" \
  --define "_libdir /usr/local/lib" \
  --define "_prefix /usr/local" \
  --buildroot $WORKSPACE/rpmbuild/BUILDROOT/

if [ $? -ne "0" ] ; then
  echo "fail - rpmbuild for SRPM build failed"
  exit -8
fi

echo "ok - applying $WORKSPACE for the new BASEDIR for mock, pattern delimiter here should be :"
# the path includeds /, so we need a diff pattern delimiter

mkdir -p "$WORKSPACE/var/lib/mock"
chmod 2755 "$WORKSPACE/var/lib/mock"
mkdir -p "$WORKSPACE/var/cache/mock"
chmod 2755 "$WORKSPACE/var/cache/mock"
sed "s:BASEDIR:$WORKSPACE:g" "$mock_cfg" > "$curr_dir/$mock_cfg_runtime"
sed -i "s:LLVM_VERSION:$LLVM_VERSION:g" "$curr_dir/$mock_cfg_runtime"
echo "ok - applying mock config $curr_dir/$mock_cfg_runtime"
cat "$curr_dir/$mock_cfg_runtime"
mock -vvv --configdir=$curr_dir -r altiscale-llvm-centos-6-x86_64.runtime --resultdir=$WORKSPACE/rpmbuild/RPMS/ --rebuild $WORKSPACE/rpmbuild/SRPMS/llvm-$LLVM_VERSION-$BUILD_TIME.el6.src.rpm --define "_libdir /usr/local/lib" --define "_prefix /usr/local"

if [ $? -ne "0" ] ; then
  echo "fail - mock RPM build failed"
  # mock --configdir=$curr_dir -r altiscale-llvm-centos-6-x86_64.runtime --clean
  mock --configdir=$curr_dir -r altiscale-llvm-centos-6-x86_64.runtime --scrub=all
  exit -9
fi

# mock --configdir=$curr_dir -r altiscale-llvm-centos-6-x86_64.runtime --clean
mock --configdir=$curr_dir -r altiscale-llvm-centos-6-x86_64.runtime --scrub=all

echo "ok - build Completed successfully!"

exit 0












