# Disk Image Builder add-on for OpenHPC-On-Openstack

%include %{_sourcedir}/CHPC_macros
%{!?OPROJ_DELIM: %global OPROJ_DELIM -ohpc}
%{!?CPROJ_DELIM: %global CPROJ_DELIM -chpc}
 
%define pname       dib-chpc
 
#BuildRoot:  %{buildroot}
Summary:        Disk Image Builder add-ons for HPC on Openstack 
License:        ASL - Apache Software License 2.0
Name:           %{pname}
Release:        0.1 
Version:	0.1
Source:         %{pname}.tar
Group:          Development/Tools
BuildRoot:  %{_tmppath}/%{pname}-%{Version}-%{Release}-root
Requires:	diskimage-builder >= 1.14
Requires:	parted >= 3.1-28
Requires:	PyYAML >= 3.10-11

%description
HPC on Openstack uses Disk Image Builder to create Openstack images for components of OpenHPC. 
This package will install the necessary scripts to deploy image builds for head nodes and compute nodes.
 
%prep
%setup -n %{pname}
 
%build
#Empty section
 
%install
mkdir -p %{buildroot}/usr/share/diskimage-builder/elements/yum/bin/
mkdir -p %{buildroot}/usr/share/diskimage-builder/elements/
mkdir -p %{buildroot}/opt/ohpc/admin/%{pname}/elements
mkdir -p %{buildroot}/opt/ohpc/admin/%{pname}/hpc-files
mv dib_patch/elements/yum/bin/install-packages %{buildroot}/usr/share/diskimage-builder/elements/yum/bin/install-packages-new
cp -fr hpc/elements/* %{buildroot}/usr/share/diskimage-builder/elements/
mv hpc/elements/* %{buildroot}/opt/ohpc/admin/%{pname}/elements/
mv hpc/hpc-files/cloud.cfg %{buildroot}/opt/ohpc/admin/%{pname}/hpc-files/
 
%files
%defattr(-,root,root)
/usr/share/diskimage-builder/elements
/opt/ohpc/admin/%{pname}/

%post

if [ -e /usr/share/diskimage-builder/elements/yum/bin/install-packages-new]
	then
		mv /usr/share/diskimage-builder/elements/yum/bin/install-packages /usr/share/diskimage-builder/elements/yum/bin/install-packages-ORIG-ohpc-dib
		mv /usr/share/diskimage-builder/elements/yum/bin/install-packages-new /usr/share/diskimage-builder/elements/yum/bin/install-packages
fi
