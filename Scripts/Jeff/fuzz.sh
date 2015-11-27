#!/bin/bash

NOW=$(date +"%m-%d-%H-%M-%S")
ip=192.168.0.111

st='get:/main.htm:b@100,ascii:ir,@1'
cmd='get:/decoder_control.cgi?command='
b1=':b@100,ascii:ir,@1'
auth=':h"Authorization"="Basic YWRtaW46cHlsZWNhbQ=="'

max=$1 #Command line option is num of iterations
good=0
bad=0
d=0

#Do a login
pathoc $ip 'get:/check_user.cgi:h"Authorization"="Basic YWRtaW46cHlsZWNhbQ=="'

STARTTIME=$(date +%s)

#Loop to fuzz
for (( i=1; i<=$max; i++ ))
do	
	d=$(( ($i*100)/$max ))
	r=$(( $RANDOM % 100 + 1 )) #Random [1..100]
	
pathoc -n 1 -t 5 -e -p -q $ip "$cmd$r$b1$auth" | tee -a "log_$NOW".txt | tee last_cmd.txt | grep 'HTTP/1.1 200 O' &> /dev/null

	if [ $? == 0 ]; then
		good=$(( $good+1 ))
		#last_out=$(<last_cmd.txt)
		#echo "$last_out" >> "log_$NOW""_good.txt"
	else
		bad=$(( $bad+1 ))
		last_out=$(<last_cmd.txt)
		echo "$last_out" >> "log_$NOW""_bad.txt"
	fi		
	echo -ne "Percent Done: $d  \tGood: $good   \tBad: $bad \r"
done

echo -ne "\n"
ENDTIME=$(date +%s)
rm last_cmd.txt

echo "END OF TESTING" >> "log_$NOW.txt"
echo "Total Tests:$max" >> "log_$NOW.txt"
echo "Elapsed Time: $(($ENDTIME - $STARTTIME)) seconds" >> "log_$NOW.txt"
numTimeouts=$(grep -c "Timeout" "log_$NOW.txt")
echo "Timeouts:$numTimeouts" >> "log_$NOW.txt"
num300=$(grep -c "HTTP/1.1 3" "log_$NOW.txt")
echo "HTTP 3XX Returns:$num300" >> "log_$NOW.txt"
num400=$(grep -c "HTTP/1.1 4" "log_$NOW.txt")
echo "HTTP 4XX Returns:$num400" >> "log_$NOW.txt"
num500=$(grep -c "HTTP/1.1 5" "log_$NOW.txt")
echo "HTTP 5XX Returns:$num500" >> "log_$NOW.txt"

echo "Finished"
