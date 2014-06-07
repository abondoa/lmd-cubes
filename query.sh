#!/usr/bin/env bash
if [[ -z "$1" ]] ;
then
    echo "Usage: ./query.sh <source-file...>"
    exit
fi;
for var in "$@"
do
    source $var
done

#if [[ -z $SESAMEPORT ]] ;
#then
#   SESAMESERVER="http://localhost:8080"
#fi;

THISHOST=$(hostname)
HOME=$BIBM/$EXTBI_RELATIVE_TO_BIBM/procedures/TPCH/
TIMESTAMP_START=$(date +%Y-%m-%d-%H-%M-%S)

if [[ -e ".query-running" ]]; then
    echo "Queries are already running, started:"
    cat .query-running
    echo "If you are sure no queries are running:"
    echo "rm .query-running"
    exit
fi

echo $TIMESTAMP_START > .query-running

mkdir $BIBM/$EXTBI_RELATIVE_TO_BIBM/data/TPCH/$THISHOST/
mkdir $BIBM/$EXTBI_RELATIVE_TO_BIBM/data/TPCH/$THISHOST/$TIMESTAMP_START/

sudo service tomcat7 restart

for TIMEOUTQUERY in $TIMEOUTQUERIES; do
    if [[ -n $VERBOSE ]]; then
        echo "Timeouting $TIMEOUTQUERY"
    fi
    echo "select
  (\"Timeout!\" as ?timeout)
where {
?S ?P ?O
} 
limit 1" > $TIMEOUTQUERY
done

MT=1
if [[ -n $TEST ]]; then
    MT=0
fi

for SCALE in $SCALES; do
    LOGGED_SCALE=$(echo "define int(x)   { auto os;os=scale;scale=0;x/=1;scale=os;return(x) }; int(l($SCALE)/l(10))" | bc -l)
    for CUBE in $CUBES ; do
        for OPTIMIZATION in  $OPTIMIZATIONS ; do
            if [[ -n $VERBOSE ]]; then
                echo $OPTIMIZATION $CUBE $SCALE $LOGGED_SCALE
            fi
            REPO=$CUBE"_sf"$LOGGED_SCALE"_"$OPTIMIZATION
            for SEED in $SEEDS; do
                if [[ -n $VERBOSE ]]; then
                    echo $BIBM/tpchdriver -uc $EXTBI_RELATIVE_TO_BIBM/queries/TPCH/$OPTIMIZATION/$CUBE"_"cube/ -mt $MT -seed $SEED -printres "$SESAMESERVER/openrdf-sesame/repositories/"$REPO | grep -v '^Reading' | grep -v '^java' | grep -v '^Using' 
                fi
                $BIBM/tpchdriver -uc $EXTBI_RELATIVE_TO_BIBM/queries/TPCH/$OPTIMIZATION/$CUBE"_"cube/ -mt $MT -seed $SEED -printres "$SESAMESERVER/openrdf-sesame/repositories/"$REPO | grep -v '^Reading' | grep -v '^java' | grep -v '^Using' 
                mkdir $BIBM/$EXTBI_RELATIVE_TO_BIBM/data/TPCH/$THISHOST/$TIMESTAMP_START/$REPO"_"$SEED/
                files=($HOME/benchmark_result.*)
                mv "${files[@]}" $BIBM/$EXTBI_RELATIVE_TO_BIBM/data/TPCH/$THISHOST/$TIMESTAMP_START/$REPO"_"$SEED/
                mv $HOME/run.log $BIBM/$EXTBI_RELATIVE_TO_BIBM/data/TPCH/$THISHOST/"run_"$REPO"_"$SEED"_"$TIMESTAMP_START".log"
                grep -Pzo '(?s)Query [0-9]* of run [0-9]* has been executed in [0-9\.]*|Query results \([0-9]*.*?\)|queryname:[0-9]*|results:\[[^\]]..*? \],|results:\[\],' $BIBM/$EXTBI_RELATIVE_TO_BIBM/data/TPCH/$THISHOST/"run_"$REPO"_"$SEED"_"$TIMESTAMP_START".log"| perl -pe 's/([0-9][0-9][0-9][0-9Ee]+)\.[0-9]*/$1/g' | perl -pe 's/([0-9]+\.[0-9Ee][0-9Ee][0-9Ee])[0-9]*/$1/g' > $BIBM/$EXTBI_RELATIVE_TO_BIBM/data/TPCH/$THISHOST/$REPO"_"$SEED.tmp
            done
        done
    done
done

rm report.txt
rm .query-running

for TIMEOUTQUERY in $TIMEOUTQUERIES; do
    svn revert $TIMEOUTQUERY
done
