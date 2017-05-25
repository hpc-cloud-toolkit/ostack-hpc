#!/usr/bin/bash

input_file="./centos7/x86_64/openstack/slurm/steps.tex"
recipe2="prepare_chpc_image"
recipe3="prepare_cloud_init"
recipe4="deploy_chpc_openstack"
recipe5="prepare_chpc_openstack"

if [ -e output.txt ]; then
	
	echo "Cleaning up previous run."
	rm -rf output.txt
	if [ -e $recipe2 ]; then
		rm $recipe2 $recipe3 $recipe4 $recipe5
	fi
fi

	echo "Running parse_docs.pl"

	perl parse_doc.pl $input_file> output.txt

#recipe1 is unused- throw-away code before the begining of the first recipe. It's the parsed data from the Intro chapter.
# the below script indexes NR-0 to recipe1, so recipes begin at recipe2


perl_outfile='output.txt' 

awk 'BEGIN{RS="\n?#   XFILEX"} (NR-1){print $0 > ("recipe_" NR)}' $perl_outfile

echo "Parsing to individual recipes"
mv recipe_2 $recipe2
mv recipe_3 $recipe3
mv recipe_4 $recipe4
mv recipe_5 $recipe5

rm -rf output.txt
