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
mkdir -p ./recipe/cloud_hpc_init/orch
mkdir -p ./recipe/hpc_cent7/ohpc/sections
mkdir -p ./recipe/hpc_cent7/intel/sections
mkdir -p ./recipe/inventory/$flavor1
mkdir -p ./recipe/inventory/$flavor2
mkdir -p ./recipe/inventory/$flavor3
mkdir -p ./recipe/hera_preq


rm -rf output.txt
rm -rf optional_*
rm -rf support_*
rm -rf heat_*
rm -rf parent_*
