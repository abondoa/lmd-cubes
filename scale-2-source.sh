if [[ -n $SCALES ]]; then
    SCALES="$SCALES 0.01"
else
    SCALES="0.01"
fi
if [[ -z $TIMEOUTQUERIES ]] ; then
   TIMEOUTQUERIES="../../queries/TPCH/snowflakeschema/lineitem_cube/query7.txt ../../queries/TPCH/snowflakeschema/lineitem_cube/query8.txt ../../queries/TPCH/snowflakeschema/lineitem_cube/query21.txt ../../queries/TPCH/starschema/lineitem_cube/query21.txt ../../queries/TPCH/denormalizedschema/lineitem_cube/query21.txt"
fi;