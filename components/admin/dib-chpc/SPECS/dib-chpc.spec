# Disk Image Builder add-on for OpenHPC-On-Openstack

%include %{_sourcedir}/CHPC_macros
%{!?OPROJ_DELIM: %global OPROJ_DELIM -ohpc}
%{!?CPROJ_DELIM: %global CPROJ_DELIM -chpc}
 
%define pname       dib-chpc
%define version     0.1
#%define buildroot %{_topdir}/%{pname}-%{version}-root
 
#BuildRoot:  %{buildroot}
Summary:        Disk Image Builder add-ons for HPC on Openstack 
License:        ASL - Apache Software License 2.0
Name:           %{pname}
Release:        0.2 
Version:	0.4
Source:         %{pname}.tar
Group:          Development/Tools
BuildRoot:  %{_tmppath}/%{pname}-%{Version}-%{Release}-root
Requires:	diskimage-builder >= 1.14

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
mkdir -p %{buildroot}/opt/ohpc/admin/%{pname}/
mv dib_patch/elements/yum/bin/install-packages %{buildroot}/usr/share/diskimage-builder/elements/yum/bin/install-packages-new
mv hpc/elements/* %{buildroot}/usr/share/diskimage-builder/elements/
mv hpc/hpc-files/cloud.cfg %{buildroot}/opt/ohpc/admin/%{pname}/
 
%files
%defattr(-,root,root)
/usr/share/diskimage-builder/elements
/opt/ohpc/admin/%{pname}/
#   /usr/share/diskimage-builder/elements/hpc-dev-env/README.rst
#   /usr/share/diskimage-builder/elements/hpc-dev-env/element-deps
#   /usr/share/diskimage-builder/elements/hpc-dev-env/element-provides
#   /usr/share/diskimage-builder/elements/hpc-dev-env/environment.d/91-hpc-dev-env
#   /usr/share/diskimage-builder/elements/hpc-dev-env/install.d/91-hpc-dev-env
#   /usr/share/diskimage-builder/elements/hpc-dev-env/post-install.d/91-hpc-dev-env
#   /usr/share/diskimage-builder/elements/hpc-env-base/README.rst
#   /usr/share/diskimage-builder/elements/hpc-env-base/element-deps
#   /usr/share/diskimage-builder/elements/hpc-env-base/element-provides
#   /usr/share/diskimage-builder/elements/hpc-env-base/environment.d/90-hpc-env-base
#   /usr/share/diskimage-builder/elements/hpc-env-base/extra-data.d/90-hpc-env-base
#   /usr/share/diskimage-builder/elements/hpc-env-base/install.d/90-hpc-env-base
#   /usr/share/diskimage-builder/elements/hpc-env-base/post-install.d/98-enable-hpc-services
#   /usr/share/diskimage-builder/elements/hpc-env-base/post-install.d/99-delete-unwanted-hpc-env
#   /usr/share/diskimage-builder/elements/hpc-env-base/pre-install.d/90-hpc-env-base
#   /usr/share/diskimage-builder/elements/hpc-mrsh/README.rst
#   /usr/share/diskimage-builder/elements/hpc-mrsh/element-deps
#   /usr/share/diskimage-builder/elements/hpc-mrsh/element-provides
#   /usr/share/diskimage-builder/elements/hpc-mrsh/environment.d/91-hpc-mrsh
#   /usr/share/diskimage-builder/elements/hpc-mrsh/install.d/91-hpc-mrsh
#   /usr/share/diskimage-builder/elements/hpc-mrsh/post-install.d/91-hpc-mrsh
#   /usr/share/diskimage-builder/elements/hpc-slurm/README.rst
#   /usr/share/diskimage-builder/elements/hpc-slurm/element-deps
#   /usr/share/diskimage-builder/elements/hpc-slurm/environment.d/92-hpc-slurm
#   /usr/share/diskimage-builder/elements/hpc-slurm/install.d/92-hpc-slurm
#   /usr/share/diskimage-builder/elements/hpc-slurm/post-install.d/92-hpc-slurm
#   /usr/share/diskimage-builder/elements/yum/bin/install-packages-new
#   /opt/ohpc/admin/%{pname}/
 
#%doc %attr(0444,root,root) /

%post

if [ -e /usr/share/diskimage-builder/elements/yum/bin/install-packages-new]
	then
		mv /usr/share/diskimage-builder/elements/yum/bin/install-packages /usr/share/diskimage-builder/elements/yum/bin/install-packages-ORIG-ohpc-dib
		mv /usr/share/diskimage-builder/elements/yum/bin/install-packages-new /usr/share/diskimage-builder/elements/yum/bin/install-packages
fi
