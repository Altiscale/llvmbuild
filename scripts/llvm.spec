%define major_ver %(echo ${LLVM_VERSION})
%define service_name llvm

Name: %{service_name}
Version: %{major_ver}
Release: 0
Summary: LLVM (An Optimizing Compiler Infrastructure)
License: University of Illinois/NCSA Open Source License
Vendor: None (open source)
Group: Development/Compilers
URL: http://llvm..org/
Source: %{_sourcedir}/%{service_name}.tar.gz
BuildRoot: %{_tmppath}/%{name}-root
Requires: /sbin/ldconfig
BuildRequires: gcc >= 3.4

%description
LLVM is a compiler infrastructure designed for compile-time, link-time, runtime,
and idle-time optimization of programs from arbitrary programming languages.
LLVM is written in C++ and has been developed since 2000 at the University of
Illinois and Apple. It currently supports compilation of C and C++ programs, 
using front-ends derived from GCC 4.0.1. A new front-end for the C family of
languages is in development. The compiler infrastructure
includes mirror sets of programming tools as well as libraries with equivalent
functionality.

%prep
echo "ok - copying files from %{_sourcedir} to folder  %{_builddir}/%{service_name}"
echo "ok - if '%setup' is specified, rpmbuild will extract the source for you, otherwise, manual copy is mandatory"
if [ -d %{_builddir}/%{service_name} ] ; then
  echo "ok - deleting previous copy of LLVM in %{_builddir}/%{service_name}"
  rm -rf %{_builddir}/%{service_name}
fi

%setup -q -n %{service_name}

%build
pushd `pwd`
cd %{_builddir}/%{service_name}/
env | sort
echo "libdir = %{_libdir}"
./configure \
--prefix=%{_prefix} \
--bindir=%{_bindir} \
--datadir=%{_datadir} \
--includedir=%{_includedir} \
--libdir=%{_libdir} \
--enable-optimized \
--enable-assertions \
--enable-docs \
--with-pic
# make tools-only
make -j4 REQUIRES_RTTI=1
make check-all
popd

%install
rm -rf %{buildroot}
echo "installing bindir = %{_bindir}"
echo "installing libdir = %{_libdir}"
echo "installing includedir = %{_includedir}"
make install DESTDIR=%{buildroot}

%clean
rm -rf %{buildroot}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(-, root, root)
%doc CREDITS.TXT LICENSE.TXT README.txt docs/*.{html,css,png} docs/CommandGuide
%{_bindir}/*
%{_libdir}/*.so
%{_libdir}/*.a
%{_libdir}/clang/
%{_includedir}/*
/usr/local/docs/llvm/
/usr/local/share/man/man1/clang.1

%changelog
* Wed Apr 09 2014 Andrew Lee
- Adjust spec for Impala, added --with-pic and --enable-docs (enforced), remove gif and jpg from doc, and *.o installation that caused the build to fail
* Fri Aug 04 2006 Reid Spencer
- Updates for release 1.8
* Fri Apr 07 2006 Reid Spencer
- Make the build be optimized+assertions
* Fri May 13 2005 Reid Spencer
- Minor adjustments for the 1.5 release
* Mon Feb 09 2003 Brian R. Gaeke
- Initial working version of RPM spec file.

