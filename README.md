llvmbuild 3.3
=============

Build LLVM 3.3 RPM for Impala with custom --with-pic option.
The original source came from http://llvm.org/releases/5.3/LLVM-2.3.tar.gz, we have archived
it on our internal S3 just in case it gets modified without notice due to no source control.

The main reason why we are building this RPM is because of Impala requires a certain version
of LLVM. Without further knowledge how Impala utilize LLVM, we will be following the docs from 
Impala.

NOTICE
======

Some tweaks were made in build.sh and llvm.spec so it is not the same as Foundry template.
Original LLVM also generates a llvm.spec file, this is slightly modified to fit our need.


How to Build
============

Create a sandbox/VM, and login as root. You can also perform this with another user. 
Building by root is not recommended.

,,,
useradd -b /home testllvm
su - testllvm
cd ~
git clone https://github.com/Altiscale/llvmbuild.git llvmbuild
cd llvmbuild
export WORKSPACE=/home/testllvm/llvmbuild
cd scripts
./build.sh
,,,

All build knowledge is embed in the llvm.spec file. The build.sh is the supportive script to 
manage environment variables and file copying, etc before invoking rpmbuild.


