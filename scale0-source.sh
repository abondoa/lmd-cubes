if [[ -n $SCALES ]]; then
    SCALES="$SCALES 1"
else
    SCALES="1"
fi
if [[ -z $TIMEOUTQUERIES ]] ; then
   TIMEOUTQUERIES="../../queries/TPCH/snowflakeschema/lineitem_cube/query7.txt ../../queries/TPCH/snowflakeschema/lineitem_cube/query8.txt ../../queries/TPCH/snowflakeschema/lineitem_cube/query21.txt ../../queries/TPCH/starschema/lineitem_cube/query21.txt ../../queries/TPCH/denormalizedschema/lineitem_cube/query21.txt ../../queries/TPCH/snowflakeschema/partsupplier_cube/query2.txt ../../queries/TPCH/starschema/partsupplier_cube/query2.txt ../../queries/TPCH/denormalizedschema/partsupplier_cube/query2.txt ../../queries/TPCH/snowflakeschema/lineitem_cube/query3.txt ../../queries/TPCH/snowflakeschema/lineitem_cube/query9.txt ../../queries/TPCH/snowflakeschema/lineitem_cube/query14.txt ../../queries/TPCH/snowflakeschema/lineitem_cube/query18.txt ../../queries/TPCH/snowflakeschema/lineitem_cube/query19.txt ../../queries/TPCH/starschema/lineitem_cube/query14.txt ../../queries/TPCH/starschema/lineitem_cube/query9.txt ../../queries/TPCH/starschema/lineitem_cube/query6.txt ../../queries/TPCH/starschema/lineitem_cube/query3.txt ../../queries/TPCH/starschema/lineitem_cube/query1.txt ../../queries/TPCH/starschema/lineitem_cube/query21.txt ../../queries/TPCH/denormalizedschema/lineitem_cube/query21.txt"
fi;