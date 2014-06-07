serveraddr=172.25.11.87
user=dba
pass=Trekant01
if [ $# -gt 0 ]
  then
    serveraddr=$1
fi
if [ $# -gt 1 ]
  then
    user=$2
    pass=
fi
if [ $# -gt 2 ]
  then
    pass=$3
fi

if [ "$(ipconfig 2> /dev/null | grep "172.25.11.87")" = "" ]
  then
    scp ../ontologies/tpc-h/tpc-h.owl admin@$serveraddr:"/cygdrive/c/Program\ Files/virtuoso-opensource-7.0.0-x64-20130802/virtuoso-opensource/rdf/tpc-h.owl" > /dev/null
  else
    cp ../ontologies/tpc-h/tpc-h.owl "/cygdrive/c/Program Files/virtuoso-opensource-7.0.0-x64-20130802/virtuoso-opensource/rdf/rdf-h.owl" > /dev/null
fi

echo "ttlp(file_to_string_output('../rdf/tpc-h.owl'),'http://extbi.lab.aau.dk/RDFH/ontologies/','http://extbi.lab.aau.dk/RDFH/ontologies',0);" | isql-vt $serveraddr $user $pass | tail -n+6 | egrep -v '^(Done\. --.*)?$' | head -n-1
echo "rdfs_rule_set('http://extbi.lab.aau.dk/RDFH/ontologies','http://extbi.lab.aau.dk/RDFH/ontologies');" | isql-vt $serveraddr $user $pass | tail -n+6 | egrep -v '^(Done\. --.*)?$' | head -n-1

