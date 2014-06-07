#!/usr/bin/env bash
if [[ -z "$1" ]] ;
then
    echo "Usage: ./load.sh <source-file...>"
    exit
fi;
for var in "$@"
do
    source $var
done

THISHOST=$(hostname)
service tomcat7 stop

for SCALE in $SCALES; do
    LOGGED_SCALE=$(echo "define int(x)   { auto os;os=scale;scale=0;x/=1;scale=os;return(x) }; int(l($SCALE)/l(10))" | bc -l)
    INPUT=$INPUT_BASE/working-dir$LOGGED_SCALE"/"
    REPO_ORIG=$REPO_BASE"original_sf"$LOGGED_SCALE"/"
    if [[ -z $NO_LOAD ]]; then
        rm -r $REPO_ORIG
        ./sesame_load_TPCH.sh --repository $REPO_ORIG --extbi $EXTBI/bin/ --tpch $TPCH --bibm $BIBM -f $SCALE -d $RDF2RDF --input $INPUT #| grep "^Time" #> $EXTBI"/data/TPCH/"$THISHOST"/load_$(date +'%Y-%m-%d-%H-%M-%S').log"
    fi
    TIMESNOW=0
    TIMEDENROM=0
    TIMESTAR=0
     
    for CUBE in $CUBES ; do
        UNDERLYING_REPO=$REPO_ORIG
        for OPTIMIZATION in  $OPTIMIZATIONS ; do
            STARTTIME=$(date +%s%3N)
            if [[ -n $VERBOSE ]] ; then
                echo $OPTIMIZATION $CUBE $SCALE $LOGGED_SCALE
                echo ./create_optimize_lineitem_cube.sh $EXTBI"/bin/sesam-1.1-jar-with-dependencies.jar" $OPTIMIZE_DIR"/"$OPTIMIZATION"/"$CUBE"-cube/" $UNDERLYING_REPO $REPO_BASE$CUBE"_sf"$LOGGED_SCALE"_"$OPTIMIZATION"/"
            fi
            if [[ $UNDERLYING_REPO = $REPO_ORIG && -n $SKIP_FIRST ]] ; then
                if [[ -n $VERBOSE ]] ; then
                    echo "NOT RUNNING THIS!"
                fi
            else
                ./create_optimize_lineitem_cube.sh $EXTBI"/bin/sesam-1.1-jar-with-dependencies.jar" $OPTIMIZE_DIR"/"$OPTIMIZATION"/"$CUBE"-cube/" $UNDERLYING_REPO $REPO_BASE$CUBE"_sf"$LOGGED_SCALE"_"$OPTIMIZATION"/" > /dev/null
            fi
            if [[ $UNDERLYING_REPO = $REPO_ORIG ]] ; then
                UNDERLYING_REPO=$REPO_BASE$CUBE"_sf"$LOGGED_SCALE"_"$OPTIMIZATION"/"
                if [[ -n $VERBOSE ]] ; then
                    echo "New underlying repo: $UNDERLYING_REPO"
                fi
            fi;
            ENDTIME=$(date +%s%3N)
            if [[ -n $TIMER ]]; then
                echo $(expr $ENDTIME - $STARTTIME)
                if [[ $OPTIMIZATION = "snowflakeschema" ]]; then
                    (( TIMESNOW+=$(expr $ENDTIME - $STARTTIME) ))
                elif [[ $OPTIMIZATION = "starschema" ]]; then
                    (( TIMESTAR+=$(expr $ENDTIME - $STARTTIME) ))
                elif [[ $OPTIMIZATION = "denormalizedschema" ]]; then
                    (( TIMEDENORM+=$(expr $ENDTIME - $STARTTIME) ))
                fi
            fi
        done
            
        
    done
    if [[ -n $TIMER ]]; then
        echo "Time QB4OLAP: "$TIMESNOW"ms"
        echo "Time SWOD-S: "$TIMESTAR"ms"
        echo "Time SWOD-D: "$TIMEDENORM"ms"
    fi
done

chmod -R g+w $REPO_BASE
chown -R tomcat7 $REPO_BASE
