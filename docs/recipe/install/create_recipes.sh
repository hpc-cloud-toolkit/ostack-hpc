#!/usr/bin/bash

#input_file="./centos7/x86_64/openstack/slurm/steps.tex"
input_file=""
input_file_slurm="./centos7/x86_64/openstack/slurm/steps.tex"
input_file_pbs="./centos7/x86_64/openstack/pbs/steps.tex"
flavor1="1_combined_controller"
flavor2="2_cloud_extension"
flavor3="3_hpc_as_service"
recipe2="prepare_chpc_image"
recipe3="NULL"
recipe4="prepare_cloud_init"
recipe5="deploy_chpc_openstack"
recipe6="prepare_chpc_openstack"
recipe7="NULL"
recipe8="update_cnodes_to_sms"
optional2="update_mrsh"
optional3="update_clustershell"
optional4="enable_genders"
optional5="NULL"
support2="README"
support3="set_os_hpc"
#support4="update_cnodes_to_sms"
heat2="heat-sms.yaml"
heat3="heat-cn.yaml"
parent2="chpc_init"
parent3="chpc_sms_init"
parent4="NULL"
parent5="common_functions"
parent6="NULL"
parent7="setup_cloud_hpc.sh"
parent8="teardown_cloud_nodes.sh"
parent9="get_cn_mac"
parent10="Template-INPUT.LOCAL"
parent11="Template-INVENTORY"


echo "There are three types of recipes, but at present only '3 - HPC as a Service' is useable."
echo "In the future there may be options to run for each type."


function generate_recipe {
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
    
    cp recipe_2 ./recipe/$flavor3/$recipe2
    cp recipe_4 ./recipe/$flavor3/$recipe4
    cp recipe_5 ./recipe/$flavor3/$recipe5
    cp recipe_6 ./recipe/$flavor3/$recipe6
    cat recipe_7 >> ./recipe/$flavor3/$recipe5
    cp recipe_8 ./recipe/$flavor3/$recipe8
    
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
    #mv support_4 ./recipe/$flavor3/$support4
    
    # Create Parent script directories
    mkdir -p recipe/cloud_hpc_init/ohpc
    mv parent_2 recipe/cloud_hpc_init/ohpc/chpc_init
    mv parent_3 recipe/cloud_hpc_init/ohpc/chpc_sms_init
    for i in 5 7 8 9; do 
        str="parent$i"
       	mv parent_$i ./recipe/${!str}
    done
    mv parent_10 recipe/Template-INPUT.LOCAL
    mv parent_11 recipe/Template-INVENTORY
    
    rm -rf output.txt
    rm -rf optional_*
    rm -rf support_*
    rm -rf recipe_*
    rm -rf heat_*
    rm -rf parent_*
     
    # Sometimes parsing the tex files generates a blank first line. The folowing simply cleans that extraneous blank line.
    
    for parsed_file in `find ./recipe`; do 
        if [[ ! -d $parsed_file ]]; then 
            readline=$(head -n 1 $parsed_file)
            if [[ -z $readline ]]; then
                tail -n +2 $parsed_file > $parsed_file.tmp
                mv $parsed_file.tmp $parsed_file
            fi
        fi
    done
}

# First generate recipe for slurm
echo "############## generating slurm recipe ########"
echo "starting"
if [ -e slurm ]; then
   rm -fr slurm
fi
input_file="./centos7/x86_64/openstack/slurm/steps.tex"
generate_recipe
# move recipe to slurm recipe
mv recipe slurm
#
# node generate pbs recipe
echo "############## generating pbs recipe ########"
if [ -e pbs ]; then
    rm -rf pbs
fi
input_file="./centos7/x86_64/openstack/pbs/steps.tex"
generate_recipe
# move recipe to slurm recipe
mv recipe pbs
