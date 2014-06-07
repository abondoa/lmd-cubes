#!/bin/bash

# getopt.sh example

# Execute getopt
ARGS=$(getopt -o b:d:e:t:s:i:r:f:cp -l "bibm:,rdf2rdf:,extbi:,tpch:,setup:,input:,repository:,scalefactor:,construct:,cleanup,split," -n "getopt.sh" -- "$@");

#################################
#        default variables      #
#################################
SF=1
LOAD="JAR"
INPUT=$(pwd)"/load-sesame-temp-dir/"
files=(nation region customer part supplier partsupp orders lineitem)
SPLIT_SIZE=5000000
REPOSITORY=""
SETUP_PATH=""
input_generate=false
input_is_split=false
input_is_construct=false
input_is_ttl=false
input_is_nt=false
input_is_tbl=false
cleanup=false
split=false
nt_files=0
ttl_files=0
split_folders=0
tbl_files=0
THISHOST=$(hostname)
#################################
#            throw errors       #
#################################
function checkRepository 
{
  if [[ -z $REPOSITORY ]]; then
    echo "(-r) Repository is not set"
    exit
  fi
}

function checkSetup
{
  if [[ -z $SETUP_PATH ]]; then
    echo "(-s) Folder for install and download of additional programs is not set."
    exit
  fi
}

function checkExtbi 
{
  if [[ -z $EXTBI ]]; then
    echo "(-e) Path to extbi is not set"
    exit
  fi
}

function checkRdf2rdf 
{
  if [[ -z $RDF2RDF_PATH ]]; then
    echo "(-d) Path to rdf2rdf is not set"
    exit
  fi
}

function checkBibm 
{
  if [[ -z $BIBM_PATH ]]; then
    echo "(-b) BIBM path is not set"
    exit
  fi
  if [ ! -f $BIBM_PATH"/tpch/virtuoso/rdfh_schema.json" ]; then
    echo "Path to bibm directs to wrong location, cannot find the tpch_schema.json file, path given:"
    echo $BIBM_PATH"/tpch/virtuoso/rdfh_schema.json"
    exit
  fi
}

function checkTpch 
{
  if [[ -z $TPCH_PATH ]]; then
    echo "(-t) TPCH path is not set"
    exit
  fi
}

function checkConstruct
{
  if [[ ! -f $CONSTRUCT && ! -d $CONSTRUCT ]]; then
    echo "Path to construct is invalid, path given: "
    echo $CONSTRUCT
    exit
  fi
}



#################################
#             input             #
#################################


function input
{
  mkdir -p $INPUT
  for f in $(ls $INPUT); do
    for tbl_file in ${files[@]}; do
      if [[ $f == $tbl_file".nt" ]]; then
        ((nt_files++))
      elif [[ $f == $tbl_file".ttl" ]]; then
        ((ttl_files++))
      elif [[ $f == $tbl_file ]]; then
        ((split_folders++))
      elif [[ $f == $tbl_file".tbl" ]]; then
        ((tbl_files++))
      fi
    done
  done

  if [[ -n $CONSTRUCT ]] ; then
    input_is_construct=true
  fi
  if [[ $split_folders -eq ${#files[@]} ]]; then
    input_is_split=true
    if [[ -n $VERBOSE ]]; then echo "split files detected"; fi 
  elif [[ $nt_files -eq ${#files[@]} ]]; then
    input_is_nt=true
    input_is_split=true
    if [[ -n $VERBOSE ]]; then echo ".nt files detected"; fi
  elif [[ $ttl_files -eq ${#files[@]} ]]; then
    input_is_ttl=true
    input_is_nt=true
    input_is_split=true
    if [[ -n $VERBOSE ]]; then echo ".ttl files detected"; fi
  elif [[ $tbl_files -eq ${#files[@]} ]]; then
    input_is_tbl=true
    input_is_ttl=true
    input_is_nt=true
    input_is_split=true
    if [[ -n $VERBOSE ]]; then echo ".tbl files detected"; fi
  else
    input_generate=true
    input_is_tbl=true
    input_is_ttl=true
    input_is_nt=true
    input_is_split=true
    echo "no valid input files, generating tbl files" 
  fi
}

#################################
#                setup          #
#################################
function setup 
{
  if [[ -n $SETUP_PATH ]]; then
    checkSetup
    mkdir -p $SETUP_PATH
    cd $SETUP_PATH

    if [[ -z $RDF2RDF_PATH ]]; then
      mkdir -p rdf2rdf
      cd rdf2rdf
      wget http://www.l3s.de/~minack/rdf2rdf/downloads/rdf2rdf-1.0.1-2.3.1.jar
      RDF2RDF_PATH=$SETUP_PATH"/rdf2rdf/"
      cd ..
    fi
      
    if [[ -z $TPCH_PATH ]]; then
      wget http://www.tpc.org/tpch/spec/tpch_2_16_1.zip
      unzip -q tpch_2_16_1.zip
      rm tpch_2_16_1.zip
      TPCH_PATH=$SETUP_PATH"/tpch_2_16_1/tpch_2_16_1/dbgen"
    fi

    if [[ -z $BIBM_PATH ]]; then
      wget "http://downloads.sourceforge.net/project/bibm/bibm-0.7.8.tgz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fbibm%2F&ts=1395653291&use_mirror=heanet" -O bibm.tar
      tar -xf bibm.tar
      rm bibm.tar
      BIBM_PATH=$SETUP_PATH"/bibm/"
    fi

    if [[ -z $EXTBI ]]; then
      mkdir -p EXTBI
      cd EXTBI
      svn checkout https://svn01.ist.aau.dk/svn/cs/Fileshares/EXTBI/bin/ .
      EXTBI=$SETUP_PATH"/rdf2rdf/EXTBI"
      cd ..
    fi
  echo "Setup is complete, run the program with these input parameters (-e "$EXTBI" -b "$BIBM_PATH" -t "$TPCH_PATH" -d "$RDF2RDF_PATH")"
  exit
fi
}

#################################
#        generate data          #
#################################
function generate_tbl
{
  cd $TPCH_PATH
  if [[ -n $VERBOSE ]]; then 
    echo "generating data";
    ./dbgen -vf -s $SF
  else
    ./dbgen -f -s $SF
  fi

  cd $INPUT
  for tbl_file in ${files[@]}
  do
    mv $TPCH_PATH/$tbl_file".tbl" .
  done
}

function convert_tbl_to_ttl
{
  if [[ -n $VERBOSE ]]; then  echo "convert to ttl"; fi
  
  cd $INPUT
  
  for tbl_file in ${files[@]}
  do
    if [[ $cleanup = true ]] ; then
      rm -f $INPUT$tbl_file".ttl" #remove ttl files if they exist
    fi
    if [[ -n $VERBOSE ]]; then
        printf $tbl_file"->ttl: "
        echo $BIBM_PATH/csv2ttl.sh -schema $BIBM_PATH"/tpch/virtuoso/rdfh_schema.json" -ext tbl $INPUT/$tbl_file".tbl"
        $BIBM_PATH/csv2ttl.sh -schema $BIBM_PATH"/tpch/virtuoso/rdfh_schema.json" -ext tbl $INPUT/$tbl_file".tbl" | grep ^Exec 
    else
        $BIBM_PATH/csv2ttl.sh -schema $BIBM_PATH"/tpch/virtuoso/rdfh_schema.json" -ext tbl $INPUT/$tbl_file".tbl" > /dev/null
    fi

    if [[ $cleanup = true ]] ; then
      rm -f $INPUT$tbl_file.tbl #clean up 
    fi
  done
}



#################################
#          clense data          #
#################################
function cleanse_datetime
{
for ttl_file in ${files[@]}
  do
    sed -i s/xsd:dateTime/xsd:date/ $INPUT/$ttl_file".ttl"
  done
}

#################################
#            Load data          #
#################################

function convert_ttl_to_nt
{
#  cd $RDF2RDF_PATH  
  for ttl_file in ${files[@]}
  do
    java $JAVA_ARGS -jar $RDF2RDF_PATH"/rdf2rdf-1.0.1-2.3.1.jar" $INPUT/$ttl_file".ttl" .nt | grep ^converting
  done
}
 
  
function split_nt_files
{
  for ttl_file in ${files[@]}
  do
    echo "splitting: "$ttl_file
    if [[ $cleanup = true ]] ; then
      rm $INPUT/$ttl_file".ttl" 
    fi
    mkdir -p $INPUT/$ttl_file
    cd $INPUT/$ttl_file
    split --lines=$SPLIT_SIZE $INPUT/$ttl_file".nt"
    if [[ $cleanup = true ]] ; then
      rm $INPUT/$ttl_file".nt"
    fi
  done
}

function add_to_custom_repository
{
  if [[ -n $VERBOSE ]]; then echo "adding data to repository"; fi
  for ttl_file in ${files[@]}
  do
    if [[ $split = true ]]; then
	if [[ -n $VERBOSE ]] ; then
      		java $JAVA_ARGS -jar $EXTBI/sesam-1.1-jar-with-dependencies.jar --verbose --load  $INPUT$ttl_file $REPOSITORY  | egrep "^(Files processed|Triples loaded)"
	else
	      java $JAVA_ARGS -jar $EXTBI/sesam-1.1-jar-with-dependencies.jar  --load  $INPUT$ttl_file $REPOSITORY > /dev/null 
	fi
	if [[ $cleanup = true ]] ; then
        	rm -r $INPUT/$ttl_file
      	fi
    else
      	if [[ -n $VERBOSE ]] ; then
		java $JAVA_ARGS -jar $EXTBI/sesam-1.1-jar-with-dependencies.jar --verbose --load  $INPUT$ttl_file".ttl" $REPOSITORY | egrep "^(Files processed|Triples loaded)"
	else
		java $JAVA_ARGS -jar $EXTBI/sesam-1.1-jar-with-dependencies.jar --load  $INPUT$ttl_file".ttl" $REPOSITORY > /dev/null
	fi
       	if [[ $cleanup = true ]] ; then
        	rm -r $INPUT$ttl_file".ttl"
      	fi
     fi
  done
}

function construct_from_repository
{
  echo "running construct queries"
  java $JAVA_ARGS -jar $EXTBI/sesam-1.1-jar-with-dependencies.jar --construct  $CONSTRUCT $REPOSITORY | egrep "^(Query processed|Reading query)"
}


#################################
#          parameters           #
#################################

eval set -- "$ARGS";

while true; do
  case "$1" in
    -b|--bibm)
      shift;
      if [ -n "$1" ]; then
        BIBM_PATH=$1 ;
        shift;
      fi
      ;;
    -t|--tpch)
      shift;
      if [ -n "$1" ]; then
        TPCH_PATH=$1 ;
        shift;
      fi
      ;;
    -d|--rdf2rdf)
      shift;
      if [ -n "$1" ]; then
        RDF2RDF_PATH=$1 ;
        shift;
      fi
      ;; 
    -c|--cleanup)
      shift;
      cleanup=true ;
      ;; 
    -p|--split)
      shift;
      split=true ;
      ;; 
    -e|--extbi)
      shift;
      if [ -n "$1" ]; then
        EXTBI=$1 ;
        shift;
      fi
      ;; 
    -s|--setup)
      shift;
      if [ -n "$1" ]; then
        SETUP_PATH=$1 ;
        shift;
      fi
      ;;
    -i|--input)
      shift;
      if [ -n "$1" ]; then
        INPUT=$1 ;        
        shift;
      fi
      ;;  
    --construct)
      shift;
      if [ -n "$1" ]; then
        CONSTRUCT=$1 ;        
        shift;
      fi
      ;;  
    -f|--scalefactor)
      shift;
      if [ -n "$1" ]; then
        SF=$1 ;
        shift;
      fi
      ;;    
    -r|--repository)
      shift;
      if [ -n "$1" ]; then
        REPOSITORY=$1 ;
        shift;
      fi
      ;;
    --)
      shift;
      break;
      ;;
  esac
done


#################################
#             main              #
#################################

##check if sufficient parameters
setup
checkRepository
input

STARTTIME=$(date +%s%3N)
if [[ $input_generate = true ]]; then
  checkTpch
  checkBibm
  checkRdf2rdf
  checkExtbi
  generate_tbl
fi
ENDTIME=$(date +%s%3N)
echo "Time generate: "$(expr $ENDTIME - $STARTTIME)"ms"

STARTTIME=$(date +%s%3N)
if [[ $input_is_tbl = true ]]; then
  checkBibm
  checkRdf2rdf
  checkExtbi
  convert_tbl_to_ttl
  cleanse_datetime
fi
ENDTIME=$(date +%s%3N)
echo "Time convert: "$(expr $ENDTIME - $STARTTIME)"ms"

if [[ $input_is_ttl = true && $split = true ]]; then
  checkRdf2rdf
  checkExtbi
  convert_ttl_to_nt
fi

if [[ $input_is_nt = true && $split = true ]]; then
  split_nt_files
fi

STARTTIME=$(date +%s%3N)
if [[ $input_is_split = true  ]]; then
  checkExtbi
  add_to_custom_repository
fi
ENDTIME=$(date +%s%3N)
echo "Time load: "$(expr $ENDTIME - $STARTTIME)"ms"


if [[ $input_is_construct = true ]]; then
  checkExtbi
  checkConstruct
  construct_from_repository
fi

if [[ -n $VERBOSE ]] ; then
	printf "Triples loaded: "
	java $JAVA_ARGS -jar $EXTBI/sesam-1.1-jar-with-dependencies.jar --query "select (count(*) as ?count) where {?a ?b ?c}" $REPOSITORY  | egrep -o "^\"[0-9]*\"\^\^" | egrep -o "[0-9]*"
fi

       
