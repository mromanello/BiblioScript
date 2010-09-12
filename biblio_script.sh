#!/usr/bin/env python
# Author: Matteo Romanello, <matteo.romanello@gmail.com>

import os,sys

# paths to executables 
# Thang v100901: minor modifications in the code so that it doesn't matter if the below directory paths end with / or not
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
	bibutils_cmd="%s/xml2bib %s"%(BIBUTILS_PATH,mods_xml)
	out=os.popen(bibutils_cmd).readlines()
	return out

# Thang v100901: process argv array
def processArgv(argv):
  inp_file=argv[1]
  out_dir=argv[2] 
  option="ref"
        
  # get option
  if(len(argv) >3):
    option=argv[3]
    if(option != "all" and option != "ref"):
      sys.stderr.write("#! Option \"%s\" is neither \"ref\" nor \"all\"\n" % option)
      sys.exit(1)
  
  # check if the input file exists
  if not os.path.isfile(inp_file):
    sys.stderr.write("#! File \"%s\" doesn't exist\n" % inp_file)
    sys.exit(1)
  
  # check if directory exists, create if not:
  if not os.path.exists(out_dir):
    sys.stderr.write("#! Directory \"%s\" doesn't exist. Creating ...\n" % out_dir)
    os.makedirs(out_dir)

  return (inp_file, out_dir, option)
# End Thang v100901: process argv array


if(len(sys.argv) >2):
        (inp_file, out_dir, option) = processArgv(sys.argv)
        print "%s\t%s\t%s" %(inp_file, out_dir, option)
        print "Extracting references from the input file..."

        # Thang v100901: handle input option
        if (option == "ref"):
          parscit_out = os.popen("%s/parseRefStrings.pl %s" %(PARSCIT_PATH,inp_file)).readlines()
        else:
          parscit_out = os.popen("%s/citeExtract.pl -m extract_citations %s" %(PARSCIT_PATH,inp_file)).readlines()
          
	parscit_xml='%s/parscit_temp.xml'%out_dir
	file = open(parscit_xml,'w')
	for line in parscit_out:
		file.write(line)
	file.close()
	
	# transform parscit's output into mods 3.x
	parscit_mods='%s/parscit_mods.xml'%out_dir
	file = open(parscit_mods,'w')
	for line in parscit_to_mods(parscit_xml):
		file.write(line)
	file.close()
	
	# transform mods intermediate xml into bibtex
	parscit_bibtex='%s/parscit.bib'%out_dir
	print "Transforming intermediate mods xml into Bibtex..."
	file = open(parscit_bibtex,'w')
	for line in mods_to_bibtex(parscit_mods):
		file.write(line)
	file.close()
		
	
else:
  # Thang v100901: add option arguments 
	print "Usage: <inputFile> <outDir> <option>"
        print "\toption=\"all\" (full-text input) or \"ref\" (input contains only individual reference strings, one per line) (default=\"ref\")"
