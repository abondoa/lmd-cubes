TEST="test"
if [[ -n $SEEDS ]]; then
    SEEDS=$(echo $SEEDS | cut -d ' ' -f 1)
else
    SEEDS="808080"
fi