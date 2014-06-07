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

if [ -s input ]
  then
    echo "input file is empty"
    exit 2;
fi

cd ../data/mappings/tpc-h;

time isql-vt $serveraddr $user $pass tpc-h.spql  | egrep -v '^00000' | egrep '(^|Error )[0-9]{5}'

