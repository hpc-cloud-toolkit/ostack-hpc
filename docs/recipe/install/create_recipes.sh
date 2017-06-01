#!/usr/bin/bash

input_file="./centos7/x86_64/openstack/slurm/steps.tex"
recipe2="prepare_chpc_image"
recipe3="prepare_cloud_init"
recipe4="deploy_chpc_openstack"
recipe5="prepare_chpc_openstack"
optional2="update_mrsh"
optional3="update_clustershell"
optional4="enable_gender"



if [ -e output.txt ]; then
	
	echo "Cleaning up previous run."
	rm -rf output.txt
	if [ -e $recipe2 ]; then
		rm $recipe2 $recipe3 $recipe4 $recipe5 $optional2 $optional3 $optional4
	fi
fi

	echo "Running parse_docs.pl"

	perl parse_doc.pl $input_file> output.txt

#recipe1 is unused- throw-away code before the begining of the first recipe. It's the parsed data from the Intro chapter.
# the below script indexes NR-0 to recipe1, so recipes begin at recipe2


perl_outfile='output.txt' 

awk 'BEGIN{RS="\n?#   XFILEX"} (NR-1){print $0 > ("recipe_" NR)}' $perl_outfile
awk 'BEGIN{RS="\n?ZFILEZ"} (NR-1){print $0 > ("optional_" NR)}' $perl_outfile


echo "Parsing to individual recipes"
mv recipe_2 $recipe2
mv recipe_3 $recipe3
mv recipe_4 $recipe4
mv recipe_5 $recipe5
if [ ! -e sms ]; then
	mkdir sms
fi
mv optional_2 sms/$optional2
mv optional_3 sms/$optional3
mv optional_4 sms/$optional4

rm -rf output.txt
rm -rf optional_*

