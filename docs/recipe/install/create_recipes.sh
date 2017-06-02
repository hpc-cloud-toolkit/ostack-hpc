#!/usr/bin/bash

input_file="./centos7/x86_64/openstack/slurm/steps.tex"
flavor="3_hpc_as_a_service"
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


if [ -e output.txt ]; then
	
	echo "Cleaning up previous run."
	rm -rf output.txt
fi
	if [ -e $flavor ]; then
		rm -rf $flavor
fi

	echo "Running parse_docs.pl"

	perl parse_doc.pl $input_file> output.txt

#recipe1 is unused- throw-away code before the begining of the first recipe. It's the parsed data from the Intro chapter.
# the below script indexes NR-0 to recipe1, so recipes begin at recipe2


perl_outfile='output.txt' 

awk 'BEGIN{RS="\n?XFILEX"} (NR-1){print $0 > ("recipe_" NR)}' $perl_outfile
awk 'BEGIN{RS="\n?ZFILEZ"} (NR-1){print $0 > ("optional_" NR)}' $perl_outfile
awk 'BEGIN{RS="\n?QFILEQ"} (NR-1){print $0 > ("support_" NR)}' $perl_outfile
awk 'BEGIN{RS="\n?HFILEH"} (NR-1){print $0 > ("heat_" NR)}' $perl_outfile

echo "Parsing to individual recipes"

if [ ! -e $flavor ]; then
        mkdir $flavor
fi

mv recipe_2 $flavor/$recipe2
mv recipe_3 $flavor/$recipe3
mv recipe_4 $flavor/$recipe4
mv recipe_5 $flavor/$recipe5

if [ ! -e $flavor/sms ]; then
	mkdir $flavor/sms
fi
mv optional_2 $flavor/sms/$optional2
mv optional_3 $flavor/sms/$optional3
mv optional_4 $flavor/sms/$optional4

if [ ! -e $flavor/heat_templates ]; then
	mkdir $flavor/heat_templates
fi
mv heat_2 $flavor/heat_templates/$heat2
mv heat_3 $flavor/heat_templates/$heat3

mv support_2 $flavor/$support2
mv support_3 $flavor/$support3
mv support_4 $flavor/$support4

rm -rf output.txt
rm -rf optional_*
rm -rf support_*
rm -rf heat_*
