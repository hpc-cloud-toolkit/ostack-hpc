#!/usr/bin/bash

input_file="./centos7/x86_64/openstack/slurm/steps.tex"
flavor1="1_combined_controller"
flavor2="2_cloud_extension"
flavor3="3_hpc_as_a_service"
recipe2="prepare_chpc_image"
recipe3="prepare_cloud_init"
recipe4="deploy_chpc_openstack"
recipe5="prepare_chpc_openstack"
optional2="update_mrsh"
optional3="update_clustershell"
optional4="enable_genders"
support2="README"
support3="set_os_hpc"
support4="update_cnodes_to_sms"
heat2="heat-sms.yaml"
heat3="heat-cn.yaml"
parent2="hera_preq/15-default.conf"
parent3="hera_preq/cmt_ohpc_inputs_dummy"
parent4="hera_preq/CentOS-Base.repo"
parent5="hera_preq/setup.sh"
parent6="hera_preq/environment"
parent7="common_functions"
parent8="c_init_workaround"
parent9="setup_cloud_hpc.sh"
parent10="hpc_cent7/intel/recipe.sh"
parent11="hpc_cent7/intel/sections/sec5-sec6:Resource_Manager_Startup.sh"
parent12="hpc_cent7/intel/sections/sec3.8-sec3.8.3:Define_compute_image_for_provisioning.sh"
parent13="hpc_cent7/intel/sections/sec3.8.4-sec3.8.4.11:Additional_Customizations_-optional-.sh"
parent14="hpc_cent7/intel/sections/sec3.1-sec3.2:Enable_required_repositories.sh"
parent15="hpc_cent7/intel/sections/sec3.4-sec3.7:Initial_HeadNode_configuration.sh"
parent16="hpc_cent7/intel/sections/sec7:CLCK_Supportability_Extensions.sh"
parent17="hpc_cent7/intel/sections/sec3.9-sec3.10:Finalize_Provisioning.sh"
parent18="hpc_cent7/intel/sections/sec4.1-sec4.7:Install_Development_Components.sh"
parent19="hpc_cent7/intel/input.local"
parent20="hpc_cent7/intel/orch_bug_wr"
parent21="hpc_cent7/intel/orch.conf"
parent22="hpc_cent7/ohpc/recipe.sh"
parent23="hpc_cent7/ohpc/ohpc.conf"
parent24="hpc_cent7/ohpc/input.local"
parent25="hpc_cent7/ohpc/ohpc_sun_hn2.conf"
parent26="hpc_cent7/ohpc/ohpc_sun_hn3.conf"
parent27="teardown_cloud_nodes.sh"
parent28="get_cn_mac"
parent29="cloud_hpc_init/orch/chpc_init"
parent30="cloud_hpc_init/ohpc/chpc_init"


echo "There are three types of recipes, but at present only '3 - HPC as a Service' is useable."
echo "In the future there may be options to run for each type."

if [ -e output.txt ]; then
	
	echo "Cleaning up previous run."
	rm -rf output.txt
fi
	if [ -e recipe ]; then
		rm -rf recipe
fi

	echo "Running parse_docs.pl"

	perl parse_doc.pl $input_file> output.txt

#recipe1 is unused- throw-away code before the begining of the first recipe. It's the parsed data from the Intro chapter.
# the below script indexes NR-0 to recipe1, so recipes begin at recipe2. This applies to all categories.


perl_outfile='output.txt' 

awk 'BEGIN{RS="\n?XFILEX"} (NR-1){print $0 > ("recipe_" NR)}' $perl_outfile
awk 'BEGIN{RS="\n?ZFILEZ"} (NR-1){print $0 > ("optional_" NR)}' $perl_outfile
awk 'BEGIN{RS="\n?QFILEQ"} (NR-1){print $0 > ("support_" NR)}' $perl_outfile
awk 'BEGIN{RS="\n?HFILEH"} (NR-1){print $0 > ("heat_" NR)}' $perl_outfile
awk 'BEGIN{RS="\n?PFILEP"} (NR-1){print $0 > ("parent_" NR)}' $perl_outfile

echo "Parsing to individual recipes"
 
mkdir -p ./recipe/$flavor3/sms
mkdir -p ./recipe/$flavor3/heat_templates

mv recipe_2 ./recipe/$flavor3/$recipe2
mv recipe_3 ./recipe/$flavor3/$recipe3
mv recipe_4 ./recipe/$flavor3/$recipe4
mv recipe_5 ./recipe/$flavor3/$recipe5

if [ ! -e ./recipe/$flavor3/sms ]; then
	mkdir ./recipe$flavor3/sms
fi
mv optional_2 ./recipe/$flavor3/sms/$optional2
mv optional_3 ./recipe/$flavor3/sms/$optional3
mv optional_4 ./recipe/$flavor3/sms/$optional4

mv heat_2 ./recipe/$flavor3/heat_templates/$heat2
mv heat_3 ./recipe/$flavor3/heat_templates/$heat3

mv support_2 ./recipe/$flavor3/$support2
mv support_3 ./recipe/$flavor3/$support3
mv support_4 ./recipe/$flavor3/$support4

# Create Parent script directories
mkdir -p ./recipe/cloud_hpc_init/ohpc
# ^^ Has 2 files
mkdir -p ./recipe/cloud_hpc_init/orch
# ^^ Has 1 file
mkdir -p ./recipe/hpc_cent7/ohpc
# ^^ Has 5 files
mkdir -p ./recipe/hpc_cent7/intel/sections
# ^^ Has 4 files in 'intel', and 8 files in 'sections'
mkdir -p ./recipe/inventory/$flavor1
# ^^ TBC later
mkdir -p ./recipe/inventory/$flavor2
# ^^ TBC Later
mkdir -p ./recipe/inventory/$flavor3
# ^^ Has 7 files, 2 subdirs: 'heat_templates' with 2 files, 'sms' with three
mkdir -p ./recipe/hera_preq
# ^^ Has 5 files

for i in `seq 2 30`; do 
	str="parent$i"
	mv parent_$i ./recipe/${!str}
done

rm -rf output.txt
rm -rf optional_*
rm -rf support_*
rm -rf heat_*
rm -rf parent_*
