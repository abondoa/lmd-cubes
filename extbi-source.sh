#!/bin/bash
if [[ -z $REPO_BASE ]] ; then
    REPO_BASE="/usr/share/tomcat7/.aduna/openrdf-sesame/repositories/"
fi;
if [[ -z $BIBM ]] ; then
    BIBM="/var/bibm/"
fi;
if [[ -z $TPCH ]] ; then
    TPCH="/var/tpch_2_16_1/dbgen/"
fi;
if [[ -z $RDF2RDF ]] ; then
    RDF2RDF="/var/EXTBI/setup/rdf2rdf/"
fi;
if [[ -z $EXTBI ]] ; then
    EXTBI="/var/EXTBI/"
fi;
if [[ -z $EXTBI_RELATIVE_TO_BIBM ]] ; then
    EXTBI_RELATIVE_TO_BIBM="../EXTBI/"
fi;
if [[ -z $SETUP ]] ; then
    SETUP="/var/EXTBI/setup"
fi;
if [[ -z $OPTIMIZE_DIR ]] ; then
    OPTIMIZE_DIR="/var/EXTBI/procedures/TPCH/optimize/"
fi;
if [[ -z $OPTIMIZATIONS ]] ; then
    OPTIMIZATIONS="snowflakeschema starschema denormalizedschema"
fi;
if [[ -z $CUBES ]] ; then
    CUBES="lineitem orders partsupplier"
fi;
if [[ -z $INPUT_BASE ]] ; then
    INPUT_BASE=`pwd`
fi;
if [[ -z $SCALES ]] ; then
    SCALES="0.001"
fi;
if [[ -z $SESAMESERVER ]] ; then
   SESAMESERVER="http://localhost:51325"
fi;
if [[ -z $SEEDS ]] ; then
   SEEDS="808080 8080 80"
fi;
export JAVA_ARGS="-Xmx2g -Xms1500m -XX:NewSize=1g"
VERBOSE="ja"
TIMER="ja"
