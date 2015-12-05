#!/bin/bash

echo "Beginning data collection from .txt files (excluding *bad.txt)"

NOW=$(date +"%m-%d-%H-%M-%S") 

echo "Aggregate Data file" >> "DataAggregate_$NOW.txt"

numTimeouts=$(grep -c "Timeout" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "Timeouts:$numTimeouts" >> "DataAggregate_$NOW.txt"
num200=$(grep -c "HTTP/1.[0-1] 200" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 200 Returns:$num200" >> "DataAggregate_$NOW.txt"
num2xx=$(grep -c "HTTP/1.[0-1] 2[0-9][1-9]" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP (non-200) 2XX Returns:$num2xx" >> "DataAggregate_$NOW.txt"
num300=$(grep -c "HTTP/1.[0-1] 3" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 3XX Returns:$num300" >> "DataAggregate_$NOW.txt"
num400=$(grep -c "HTTP/1.[0-1] 400" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 400 Returns:$num400" >> "DataAggregate_$NOW.txt"
num401=$(grep -c "HTTP/1.[0-1] 401" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 401 Returns:$num401" >> "DataAggregate_$NOW.txt"
num403=$(grep -c "HTTP/1.[0-1] 403" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 403 Returns:$num403" >> "DataAggregate_$NOW.txt"
num404=$(grep -c "HTTP/1.[0-1] 404" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 404 Returns:$num404" >> "DataAggregate_$NOW.txt"
num4xx=$(grep -c "HTTP/1.[0-1] 4[0-9][5-9]" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 405-499 returns:$num4xx" >> "DataAggregate_$NOW.txt"
num500=$(grep -c "HTTP/1.[0-1] 500" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 500 Returns:$num500" >> "DataAggregate_$NOW.txt"
num501=$(grep -c "HTTP/1.[0-1] 501" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 501 Returns:$num501" >> "DataAggregate_$NOW.txt"
num5xx=$(grep -c "HTTP/1.[0-1] 5[0-9][2-9]" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "HTTP 502-599 Returns:$num5xx" >> "DataAggregate_$NOW.txt"
numInv=$(grep -c "Invalid server response" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "Invalid server response: Server disconnect:$numInv" >> "DataAggregate_$NOW.txt"
numNull=$(grep -c "(null)" *[0-9].txt | awk 'BEGIN{FS=":"}{x+=$2}END{print x}')
echo "(null) Returns:$numNull" >> "DataAggregate_$NOW.txt"

sumNum=$(($numTimeouts+$num200+$num2xx+$num300+$num400+$num401+$num403+$num404+$num4xx+$num500+$num501+$num5xx+$numInv+$numNull))
echo "Sum of counted returns: $sumNum"  >> "DataAggregate_$NOW.txt"

numTests=$(grep "Total Tests" *[0-9].txt | awk 'BEGIN{FS=":Total Tests:"}{x+=$2}END{print x}')
echo "Expected Total Number of Tests:$numTests">> "DataAggregate_$NOW.txt"
diff=$((numTests-sumNum))
echo "Unaccounted Responses:$diff"  >> "DataAggregate_$NOW.txt"

echo ""
tail  --lines=8 "DataAggregate_$NOW.txt"

echo "Finished"
echo ""
