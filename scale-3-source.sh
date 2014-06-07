if [[ -n $SCALES ]]; then
    SCALES="$SCALES 0.001"
else
    SCALES="0.001"
fi
if [[ -z $TIMEOUTQUERIES ]] ; then
   TIMEOUTQUERIES="../../queries/TPCH/snowflakeschema/lineitem_cube/query7.txt"
fi;