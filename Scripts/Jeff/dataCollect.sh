#!/bin/bash

echo "Beginning data collection from .txt files (excluding *bad.txt)"

NOW=$(date +"%m-%d-%H-%M-%S") 

echo "Aggregate Data file" >> "DataAggregate_$NOW.txt"

numTimeouts=$(grep -c "Timeout" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "Timeouts:$numTimeouts" >> "DataAggregate_$NOW.txt"

num2xx=$(grep -c "HTTP/1.[0-1] 2[0-9][1-9]" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP (non-200) 2XX Returns:$num2xx" >> "DataAggregate_$NOW.txt"
num300=$(grep -c "HTTP/1.[0-1] 3" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 3XX Returns:$num300" >> "DataAggregate_$NOW.txt"
num400=$(grep -c "HTTP/1.[0-1] 4" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 4XX Returns:$num400" >> "DataAggregate_$NOW.txt"
num500=$(grep -c "HTTP/1.[0-1] 5" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 5XX Returns:$num500" >> "DataAggregate_$NOW.txt"

echo ""
tail  --lines=8 "DataAggregate_$NOW.txt"

echo "Finished"
echo ""
