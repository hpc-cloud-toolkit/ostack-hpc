# Disk Image Builder add-on for OpenHPC-On-Openstack
 
%define name        ohpc-dib
%define release     1.0
%define version     1.0
%define buildroot %{_topdir}/%{name}-%{version}-root
 
BuildRoot:  %{buildroot}
Summary:        Disk Image Builder add-ons for OpenHPC on Openstack 
License:        ASL - Apache Software License 2.0
Name:           %{name}
Release:        %{release}
Version:	%{version}
Source:         %{name}-%{version}.tar.gz
Group:          Development/Tools
Requires:	diskimage-builder >= 1.14

%description
OpenHPC on Openstack uses Disk Image Builder to create Openstack images for components of OpenHPC. 
This package will install the necessary scripts to deploy image builds for head nodes and compute nodes.
 
%prep
%autosetup
 
%build
#Empty section
 
%install
cp -r * %{buildroot}
 
%files
%defattr(-,root,root)
   /usr/share/diskimage-builder/elements/hpc-dev-env/README.rst
   /usr/share/diskimage-builder/elements/hpc-dev-env/element-deps
   /usr/share/diskimage-builder/elements/hpc-dev-env/element-provides
   /usr/share/diskimage-builder/elements/hpc-dev-env/environment.d/91-hpc-dev-env
   /usr/share/diskimage-builder/elements/hpc-dev-env/install.d/91-hpc-dev-env
   /usr/share/diskimage-builder/elements/hpc-dev-env/post-install.d/91-hpc-dev-env
   /usr/share/diskimage-builder/elements/hpc-env-base/README.rst
   /usr/share/diskimage-builder/elements/hpc-env-base/element-deps
   /usr/share/diskimage-builder/elements/hpc-env-base/element-provides
   /usr/share/diskimage-builder/elements/hpc-env-base/environment.d/90-hpc-env-base
   /usr/share/diskimage-builder/elements/hpc-env-base/extra-data.d/90-hpc-env-base
   /usr/share/diskimage-builder/elements/hpc-env-base/install.d/90-hpc-env-base
   /usr/share/diskimage-builder/elements/hpc-env-base/post-install.d/98-enable-hpc-services
   /usr/share/diskimage-builder/elements/hpc-env-base/post-install.d/99-delete-unwanted-hpc-env
   /usr/share/diskimage-builder/elements/hpc-env-base/pre-install.d/90-hpc-env-base
   /usr/share/diskimage-builder/elements/hpc-mrsh/README.rst
   /usr/share/diskimage-builder/elements/hpc-mrsh/element-deps
   /usr/share/diskimage-builder/elements/hpc-mrsh/element-provides
   /usr/share/diskimage-builder/elements/hpc-mrsh/environment.d/91-hpc-mrsh
   /usr/share/diskimage-builder/elements/hpc-mrsh/install.d/91-hpc-mrsh
   /usr/share/diskimage-builder/elements/hpc-mrsh/post-install.d/91-hpc-mrsh
   /usr/share/diskimage-builder/elements/hpc-slurm/README.rst
   /usr/share/diskimage-builder/elements/hpc-slurm/element-deps
   /usr/share/diskimage-builder/elements/hpc-slurm/environment.d/92-hpc-slurm
   /usr/share/diskimage-builder/elements/hpc-slurm/install.d/92-hpc-slurm
   /usr/share/diskimage-builder/elements/hpc-slurm/post-install.d/92-hpc-slurm
   /usr/share/diskimage-builder/elements/yum/bin/install-packages-new
   /opt/ohpc/admin/cloud_hpc_init	
 
#%doc %attr(0444,root,root) /

%post

if [ -e /usr/share/diskimage-builder/elements/yum/bin/install-packages-new]
	then
		mv /usr/share/diskimage-builder/elements/yum/bin/install-packages /usr/share/diskimage-builder/elements/yum/bin/install-packages-ORIG-ohpc-dib
		mv /usr/share/diskimage-builder/elements/yum/bin/install-packages-new /usr/share/diskimage-builder/elements/yum/bin/install-packages
fi
