#!/usr/bin/env python
# Author: Matteo Romanello, <matteo.romanello@gmail.com>

import os,sys

# paths to executables 
PARSCIT_PATH="/Applications/ParsCit/bin/"
BIBUTILS_PATH="/Applications/bibutils_4.8/"
SAXON_PATH="/Applications/saxonhe9-2-1-2j/saxon9he.jar"

# paths to resources
XSLT_TRANFORM_PATH="./parscit2mods.xsl"

def parscit_to_mods(parscit_out):
	saxon_cmd="java -jar %s -xsl:%s -s:%s" %(SAXON_PATH,XSLT_TRANFORM_PATH,parscit_out)
	out=os.popen(saxon_cmd).readlines()
	print "Transforming Parscit's output into mods xml..."
	return out
	
def mods_to_bibtex(mods_xml):
	bibutils_cmd="%sxml2bib %s"%(BIBUTILS_PATH,mods_xml)
	out=os.popen(bibutils_cmd).readlines()
	return out

if(len(sys.argv)>1):
	inp_file=sys.argv[1] #I should check that this file exists
	out_dir=sys.argv[2] #I should check that this directory exists
	print "Extracting references from the input file..."
	parscit_out = os.popen("%sparseRefStrings.pl %s" %(PARSCIT_PATH,inp_file)).readlines()
	parscit_xml='%sparscit_temp.xml'%out_dir
	file = open(parscit_xml,'w')
	for line in parscit_out:
		file.write(line)
	file.close()
	
	# transform parscit's output into mods 3.x
	parscit_mods='%sparscit_mods.xml'%out_dir
	file = open(parscit_mods,'w')
	for line in parscit_to_mods(parscit_xml):
		file.write(line)
	file.close()
	
	# transform mods intermediate xml into bibtex
	parscit_bibtex='%sparscit.bib'%out_dir
	print "Transforming intermediate mods xml into Bibtex..."
	file = open(parscit_bibtex,'w')
	for line in mods_to_bibtex(parscit_mods):
		file.write(line)
	file.close()
		
	
else:
	print"Usage: <inputFile> <outDir>"