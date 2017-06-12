#----------------------------------------------------------------------------
# This RPM .spec file is part of the OpenHPC project.
#
# It may have been modified from the default version supplied by the underlying
# release package (if available) in order to apply patches, perform customized
# build/install configurations, and supply additional files to support
# desired integration conventions.
#
#----------------------------------------------------------------------------

%include %{_sourcedir}/ohpc-hpcaas_macros

%define name        ohpc-hpcaas-docs
%define release     0.1
%define version     0.1
%define buildroot %{_topdir}/%{name}-1.0-root

BuildRoot:  	%{_tmppath}/%{name}-%{version}-build
Summary:        Documentationfor OpenHPC on Openstack
License:        ASL - Apache Software License 2.0
Name:           %{name}
Release:        %{release}
Version:        %{version}
Source0:         %{name}-%{version}.tar.gz
Source1:         ohpc-hpcaas_macros
Group:          Development/Tools

BuildRequires:  texlive-latex
BuildRequires:  texlive-caption
BuildRequires:  texlive-colortbl
BuildRequires:  texlive-fancyhdr
BuildRequires:  texlive-mdwtools
BuildRequires:  texlive-multirow
BuildRequires:  texlive-tcolorbox
BuildRequires:  latexmk
BuildRequires:  git
Requires:       make
Requires:       net-tools

%description 

This guide presents the installation of OpenHPC on an Openstack infrastructure. 

%prep
%autosetup

%build
pwd
cd centos7/x86_64/openstack/slurm/
make
cd ../../../..
bash create_recipes.sh


pushd centos7/x86_64/openstack/slurm

%install

%{__mkdir_p} %{buildroot}%{OHPC_PUB}/doc
%{__mkdir_p} %{buildroot}%{OHPC_PUB}/doc/recipes/cloudhpc/cloud_hpc_init/ohpc

%define lpath centos7/x86_64/openstack/slurm
install -m 0644 -p -D %{lpath}/steps.pdf %{buildroot}/%{OHPC_PUB}/doc/recipes/%{lpath}/OHPC-HPCaaS-Install_guide.pdf
install -m 0755 -p -d recipe %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc

install -m 0755 -p -D recipe/common_functions %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
install -m 0755 -p -d recipe/3_hpc_as_a_service %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/set_os_hpc %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -d recipe/3_hpc_as_a_service/sms %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/sms/update_mrsh %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/sms/update_clustershell %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/sms/enable_genders %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/update_cnodes_to_sms %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/deploy_chpc_openstack %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/prepare_chpc_image %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -d recipe/3_hpc_as_a_service/heat_templates %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/heat_templates/heat-cn.yaml %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/heat_templates/heat-sms.yaml %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/prepare_chpc_openstack %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/prepare_cloud_init %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/3_hpc_as_a_service/README %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
install -m 0755 -p -D recipe/setup_cloud_hpc.sh %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
install -m 0755 -p -D recipe/teardown_cloud_nodes.sh %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
install -m 0755 -p -D recipe/get_cn_mac %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
install -m 0755 -p -d recipe/cloud_hpc_init %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc/cloud_hpc_init
#install -m 0755 -p -d recipe/cloud_hpc_init/ohpc %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/cloud_hpc_init/ohpc/chpc_init %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc
#install -m 0755 -p -D recipe/cloud_hpc_init/ohpc/chpc_sms_init %{buildroot}%/%{OHPC_PUB}/doc/recipes/cloudhpc

%{__mkdir_p} ${RPM_BUILD_ROOT}/%{_docdir}


%files

%defattr(-,root,root)
%dir %{OHPC_HOME}
%{OHPC_PUB}

%changelog

%post
