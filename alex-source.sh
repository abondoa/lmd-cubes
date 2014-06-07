#!/bin/bash
if [[ -z $REPO_BASE ]] ; then
    REPO_BASE="/usr/share/tomcat7/.aduna/openrdf-sesame/repositories/"
fi;
if [[ -z $BIBM ]] ; then
    BIBM="/home/alex/code-playground/bibm/"
fi;
if [[ -z $TPCH ]] ; then
    TPCH="/home/alex/code-playground/tpch_2_16_1/dbgen/"
fi;
if [[ -z $RDF2RDF ]] ; then
    RDF2RDF="/home/alex/Documents/10sem/sw10/setup/rdf2rdf/"
fi;
if [[ -z $EXTBI ]] ; then
    EXTBI="/home/alex/Documents/10sem/sw10"
fi;
if [[ -z $EXTBI_RELATIVE_TO_BIBM ]] ; then
    EXTBI_RELATIVE_TO_BIBM="../../Documents/10sem/sw10"
fi;
if [[ -z $SETUP ]] ; then
    SETUP="/home/alex/Documents/10sem/sw10/setup"
fi;
if [[ -z $OPTIMIZE_DIR ]] ; then
    OPTIMIZE_DIR="/home/alex/Documents/10sem/sw10/procedures/TPCH/optimize/"
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
   SESAMESERVER="http://localhost:8080"
fi;
if [[ -z $SEEDS ]] ; then
   SEEDS="808080 8080 80"
fi;
if [[ -z $THISHOST ]] ; then
    THISHOST=$(hostname)
fi;
export JAVA_ARGS="-Xmx2g -Xms1500m -XX:NewSize=1g"
VERBOSE="Hvis der står noget her er den slået til, så det er den nu. Det er lige meget hvad der står :)"
TIMER="ja"
