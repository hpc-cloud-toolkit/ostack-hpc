#----------------------------------------------------------------------------bh-
# This RPM .spec file is part of the OpenHPC project.
#
# It may have been modified from the default version supplied by the underlying
# release package (if available) in order to apply patches, perform customized
# build/install configurations, and supply additional files to support
# desired integration conventions.
#
#----------------------------------------------------------------------------eh-

%include %{_sourcedir}/CHPC_macros
%include %{_sourcedir}/release_macros
%{!?OPROJ_DELIM: %global OPROJ_DELIM -ohpc}
%{!?CPROJ_DELIM: %global CPROJ_DELIM -chpc}

Summary:   Integration test suite for OpenHPC
Name:      test-suite%{CPROJ_DELIM}
Release:   %{CHPC_RELEASE}
Version:   %{CHPC_VERSION}
License:   Apache-2.0
Group:     %{PROJ_BASE}/admin
BuildArch: noarch
#URL:       https://github.com/openhpc/ohpc/tests
Source0:   tests-chpc.tar
Source1:   CHPC_macros

BuildRequires:  autoconf >= 2.69
BuildRequires:  automake >= 1.13
Requires:  autoconf-ohpc >= 2.69
Requires:  automake-ohpc >= 1.13
Requires:  test-suite-ohpc >= 1.3

%if 0%{?suse_version} >= 1230
Requires(pre):  shadow
%endif

BuildRoot: %{_tmppath}/%{pname}-%{version}-%{release}-root
DocDir:    %{OHPC_PUB}/doc/contrib

%define testuser ohpc-test
%define debug_package %{nil}

%description

This package provides a suite of integration tests used by the OpenHPC project
during continuous integration. Most components can be tested individually, but
a default configuration is setup to enable collective testing. The test suite
is made available under an '%{testuser}' user account.

%prep
%setup -n tests-chpc

%build
export PATH=/opt/ohpc/pub/autotools/bin:$PATH
cd tests
#./bootstrap


%install

%{__mkdir_p} %{buildroot}/home/%{testuser}/
cp -a * %{buildroot}/home/%{testuser}/
find %{buildroot}/home/%{testuser}/ -name .gitignore  -exec rm {} \;

%clean
rm -rf $RPM_BUILD_ROOT

%pre
getent passwd %{testuser} >/dev/null || \
    /usr/sbin/useradd -U -c "CloudHPC integration test account" \
    -s /bin/bash -m -b /home %{testuser}
exit 0

%post

%postun

%files
%defattr(-,%{testuser},%{testuser},-)
%dir /home/%{testuser}
/home/%{testuser}/tests



