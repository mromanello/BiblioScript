#!/usr/bin/env python
# Author: Matteo Romanello, <matteo.romanello@gmail.com>

import os,sys,getopt,re

# paths to executables 
# Thang v100901: minor modifications in the code so that it doesn't matter if the below directory paths end with / or not
#PARSCIT_PATH="/Applications/ParsCit/bin/"
#IBUTILS_PATH="/Applications/bibutils_4.8/"
#SAXON_PATH="/Applications/saxonhe9-2-1-2j/saxon9he.jar"

PARSCIT_PATH="/home/lmthang/RA/parscit/bin"
BIBUTILS_PATH="/home/lmthang/RA/BiblioScript/thang/bibutils_4.10"
SAXON_PATH="/home/lmthang/RA/BiblioScript/thang/saxonhe9-2-1-2j/saxon9he.jar"

# paths to resources
XSLT_TRANFORM_PATH="./parscit2mods.xsl"

def parscit_to_mods(parscit_out):
	saxon_cmd="java -jar %s -xsl:%s -s:%s" %(SAXON_PATH,XSLT_TRANFORM_PATH,parscit_out)
	out=os.popen(saxon_cmd).readlines()
	print "Transforming Parscit's output into mods xml..."
	return out
	
def export_mods(mods_xml, out_type):
	bibutils_cmd="%s/xml2%s %s"%(BIBUTILS_PATH, out_type, mods_xml) # Thang v100901: modify to add multiple export format
	out=os.popen(bibutils_cmd).readlines()
	return out

def usage():
	print "Usage: %s [-h] [-m <mode>] [-o <outputType>] <inputFile> <outDir>" %(sys.argv[0])
        print "Options:"
        print "\t-h\tPrint this mesage"
        print "\t-m <mode>\tMode=\"all\" (full-text input) or \"ref\" (input contains only individual reference strings, one per line) (default=\"ref\")"
        print "\t-o <outputType>\tType=(ads|bib|end|isi|ris|wordbib) (default=bib)"

# Thang v100901: process argv array using getopt
def process_argv(argv):
  try:
    opts, args = getopt.getopt(argv[1:], "hm:o:", ["help", "mode=", "output="])
  except getopt.GetoptError, err:
    print str(err)
    usage()
    sys.exit(2)

  mode = "ref"
  out_type = "bib"

  for o, a in opts:
    if o in ("-h", "--help"):
      usage()
      sys.exit()
    elif o in ("-m", "--mode"):
      mode = a
      if(mode != "all" and option != "ref"):
        sys.stderr.write("#! mode \"%s\" is neither \"ref\" nor \"all\"\n" % option)
        sys.exit(1)
    elif o in ("-o", "--output"):
      out_type = a

      if(not re.match("(ads|bib|end|isi|ris|word)", out_type)):
        sys.stderr.write("#! Output type \"%s\" does not match(ads|bib|end|isi|ris|wordbib)\n" % out_type)
        sys.exit(1)
  
    else:
      assert False, "unhandled mode"

  if(len(args) > 1):
    inp_file = args[0]
    out_dir = args[1]
 
  sys.stderr.write("# (mode, outputType, inputFile, outDir) = (\"%s\", \"%s\", \"%s\", \"%s\")\n" %(mode, out_type, inp_file, out_dir))

  # check if the input file exists
  if not os.path.isfile(inp_file):
    sys.stderr.write("#! File \"%s\" doesn't exist\n" % inp_file)
    sys.exit(1)
  
  # check if directory exists, create if not:
  if not os.path.exists(out_dir):
    sys.stderr.write("#! Directory \"%s\" doesn't exist. Creating ...\n" % out_dir)
    os.makedirs(out_dir)

  return (out_type, mode, inp_file, out_dir)
# End Thang v100901: process argv array

### Main program ###        
(out_type, mode, inp_file, out_dir) = process_argv(sys.argv)

print "# Extracting references from the input file..."

# Thang v100901: handle mode
if (mode == "ref"):
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
	
# transform mods intermediate xml into other export format
# Thang v100901: modify to handle multiple format 
export_file='%s/parscit.%s' %(out_dir, out_type)
print "# Transforming intermediate mods xml into %s format. Output to %s ..." % (out_type, export_file)
file = open(export_file,'w')
for line in export_mods(parscit_mods, out_type):
	file.write(line)
file.close()

