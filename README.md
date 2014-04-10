llvmbuild
=========

Build LLVM 3.3 RPM for Impala with custom --with-pic option.

NOTICE
======

Some tweaks were made in build.sh and llvm.spec so it is not the same as Foundry template.


How to Build
============

Create a sandbox/VM, and login as root. You can also perform this with another user. Root is not 
recommended.

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

