#----------------------------------------------------------------------------
# This RPM .spec file is part of the OpenHPC project.
#
# It may have been modified from the default version supplied by the underlying
# release package (if available) in order to apply patches, perform customized
# build/install configurations, and supply additional files to support
# desired integration conventions.
#
#----------------------------------------------------------------------------

%include %{_sourcedir}/CHPC_macros
%include %{_sourcedir}/release_macros
%{!?OPROJ_DELIM: %global OPROJ_DELIM -ohpc}
%{!?CPROJ_DELIM: %global CPROJ_DELIM -chpc}

%define pname       docs

Summary:        Documentation for HPC on Openstack
License:        ASL - Apache Software License 2.0
Name:           docs%{CPROJ_DELIM}
Release:        %{CHPC_RELEASE}
Version:        %{CHPC_VERSION}
Source0:        docs-%{PROJ_NAME}.tar
Source1:        CHPC_macros
Group:          Development/Tools
BuildRoot:  	%{_tmppath}/%{pname}-%{Version}-root

BuildRequires:  texlive-latex
BuildRequires:  texlive-caption
BuildRequires:  texlive-colortbl
BuildRequires:  texlive-fancyhdr
BuildRequires:  texlive-mdwtools
BuildRequires:  texlive-multirow
BuildRequires:  texlive-tcolorbox
BuildRequires:  latexmk
BuildRequires:  texlive-environ
BuildRequires:  texlive-trimspaces
BuildRequires:  git
Requires:       make
Requires:       net-tools

%description 

This guide presents the installation of OpenHPC on an Openstack infrastructure. 

%prep
%setup -n %{pname}%{CPROJ_DELIM}

%build
pwd
ls
cd recipe/install
cd centos7/x86_64/openstack/slurm/
make
cd ../../../..
bash create_recipes.sh

pushd centos7/x86_64/openstack/slurm

%install

%{__mkdir_p} %{buildroot}%{OHPC_PUB}/doc
#%{__mkdir_p} %{buildroot}%{OHPC_PUB}/doc/recipes/cloudhpc/cloud_hpc_init/ohpc

%define s_path install/centos7/x86_64/openstack/slurm
%define d_path %{OHPC_PUB}/doc/recipes/centos7/x86_64/openstack/slurm
%define lpath install/centos7/x86_64/openstack/slurm
%define grecipe recipe/install/recipe
install -m 0755 -p -d recipe/%{s_path} %{buildroot}/%{d_path}
install -m 0644 -p -D recipe/%{s_path}/steps.pdf %{buildroot}/%{d_path}/OHPC-HPCaaS-Install_guide.pdf
install -m 0755 -p -D %{grecipe}/common_functions %{buildroot}/%{d_path}/
install -m 0755 -p -D %{grecipe}/setup_cloud_hpc.sh %{buildroot}/%{d_path}/
install -m 0755 -p -D %{grecipe}/teardown_cloud_nodes.sh %{buildroot}/%{d_path}/
install -m 0755 -p -D %{grecipe}/get_cn_mac %{buildroot}/%{d_path}/
install -m 0755 -p -d %{grecipe}/3_hpc_as_service %{buildroot}/%{d_path}/3_hpc_as_service
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/set_os_hpc %{buildroot}/%{d_path}/3_hpc_as_service/
install -m 0755 -p -d %{grecipe}/3_hpc_as_service/heat_templates %{buildroot}/%{d_path}/3_hpc_as_service/heat_templates
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/heat_templates/heat-cn.yaml %{buildroot}/%{d_path}//3_hpc_as_service/heat_templates/
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/heat_templates/heat-sms.yaml %{buildroot}/%{d_path}//3_hpc_as_service/heat_templates/

install -m 0755 -p -d %{grecipe}/3_hpc_as_service/sms %{buildroot}/%{d_path}/3_hpc_as_service/sms/
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/sms/update_mrsh %{buildroot}/%{d_path}//3_hpc_as_service/sms/
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/sms/update_clustershell %{buildroot}/%{d_path}//3_hpc_as_service/sms/
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/sms/enable_genders %{buildroot}/%{d_path}//3_hpc_as_service/sms/
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/update_cnodes_to_sms %{buildroot}/%{d_path}//3_hpc_as_service/
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/deploy_chpc_openstack %{buildroot}/%{d_path}//3_hpc_as_service/
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/prepare_chpc_image %{buildroot}/%{d_path}//3_hpc_as_service/
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/prepare_chpc_openstack %{buildroot}/%{d_path}//3_hpc_as_service/
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/prepare_cloud_init %{buildroot}/%{d_path}//3_hpc_as_service/
install -m 0755 -p -D %{grecipe}/3_hpc_as_service/README %{buildroot}/%{d_path}//3_hpc_as_service/
install -m 0755 -p -d %{grecipe}/cloud_hpc_init %{buildroot}/%{d_path}/cloud_hpc_init
install -m 0755 -p -d %{grecipe}/cloud_hpc_init/ohpc %{buildroot}/%{d_path}/cloud_hpc_init/ohpc
install -m 0755 -p -D %{grecipe}/cloud_hpc_init/ohpc/chpc_init %{buildroot}/%{d_path}/cloud_hpc_init/ohpc/
install -m 0755 -p -D %{grecipe}/cloud_hpc_init/ohpc/chpc_sms_init %{buildroot}/%{d_path}/cloud_hpc_init/ohpc/
# Install templates input files
install -m 0755 -p -D %{grecipe}/Template-INPUT.LOCAL %{buildroot}/%{OHPC_PUB}/doc/recipes/
install -m 0755 -p -D %{grecipe}/Template-INVENTORY %{buildroot}/%{OHPC_PUB}/doc/recipes/

%{__mkdir_p} ${RPM_BUILD_ROOT}/%{_docdir}


%files

%defattr(-,root,root)
%dir %{OHPC_HOME}
%{OHPC_PUB}

%changelog

%post
