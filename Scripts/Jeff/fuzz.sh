#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo ""
    echo " Usage:	./fuzz.sh <IPADDR> <CAMERA> <TESTS>"
    echo "		"
    echo "	IPADDR to fuzz, in the form xxx.xxx.xxx.xxx"
    echo "	CAMERA  1=PYLE, 2=DLINK"
    echo "	TESTS, number of tests to perform, ie: 500"
    echo ""
    exit 1;	
fi

NOW=$(date +"%m-%d-%H-%M-%S")
#ip=192.168.0.111
ip=$1
echo "IP: $ip"
camera=$2
echo "Camera: $camera"
max=$3 #Command line option is num of iterations
echo "Tests: $max"

STARTTIME=$(date +%s)
good=0
bad=0
d=0


####################################################################
#########################    PYLE    ##################################

if [ "$camera" -eq 1 ]; then #start setup for PYLE camera
   cmd='get:/decoder_control.cgi?command='
   auth=':h"Authorization"="Basic YWRtaW46cHlsZWNhbQ=="'
   #Do a login
   pathoc $ip 'get:/check_user.cgi:h"Authorization"="Basic YWRtaW46cHlsZWNhbQ=="'


st='get:/main.htm:b@100,ascii:ir,@1'
b1=':b@100,ascii:ir,@1'

#Loop to fuzz PYLE
for (( i=1; i<=$max; i++ ))
do	
	d=$(( ($i*100)/$max ))
	r=$(( $RANDOM % 100 + 1 )) #Random [1..100]
	
pathoc -n 1 -t 5 -e -p -q $ip "$cmd$r$b1$auth" | tee -a "log_$NOW".txt | tee last_cmd.txt | grep 'HTTP/1.1 2*' &> /dev/null

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

####################################################################
#########################    DLINK   ##################################

####################
# DLINK .cgi pages
# /audiocontrol.cgi
# /nightmodecontrol.cgi
# /image/jpeg.cgi
# 
#####################

else #start fuzzing DLINK camera
   cmd='get:/nigthmodecontrol.cgi?command='
   auth=':h"Authorization"="Basic YWRtaW46YjNZb25kQ2FtZmluaXR5TUtF"'


for (( i=1; i<=$max; i++))
do
  r=$(( $RANDOM % 100)) #Random [0-99]
  d=$(( ($i*100)/$max ))
  echo -ne "Percent Done: $d \r"
 modCase=$(( ($i % 7) )) 
#modCase=3 #force only one case for now
 case $modCase in
0)
  #valid request with random 50 chars
 pathoc -n 1 -t 5 -e -q -p $ip 'get:/image/jpeg.cgi:b@100,ascii:ir,@50h"Authorization"="Basic YWRtaW46YjNZb25kQ2FtZmluaXR5TUtF" '  | tee -a "log_$NOW".txt | tee last_cmd.txt | grep 'HTTP/1.[0-1] 2' &> /dev/null
  
  #pathoc -n 1 -t 5 -e -q -p $ip 'get:/:b@100,ascii:ir,@5h"Authorization"="Basic YWR" '  | tee -a "log_$NOW".txt | tee last_cmd.txt | grep 'HTTP/1.[0-1] 2' &> /dev/null
  ;;
1)
  #long get request
  pathoc -n 1 -t 5 -e -p -q  $ip 'get:@70000,ascii:b@100,ascii:h"Authorization"="Basic YWRtaW46YjNZb25kQ2FtZmluaXR5TUtF" '  | tee -a "log_$NOW".txt | tee last_cmd.txt | grep 'HTTP/1.[0-1] 2' &> /dev/null 
  ;;
2)
   #long header
  pathoc -n 1 -t 5 -e -p -q  $ip 'get:/image/jpeg.cgi:b@100,ascii:h@70000,ascii="" ' | tee -a "log_$NOW".txt | tee last_cmd.txt | grep 'HTTP/1.[0-1] 2' &> /dev/null
  ;;
3)
  #long header
  pathoc -n 1 -t 5 -e -p -q  $ip 'get:/image/jpeg.cgi:b@100,ascii:h@70000,ascii="" ' | tee -a "log_$NOW".txt | tee last_cmd.txt | grep 'HTTP/1.[0-1] 2' &> /dev/null
  ;;
4)
 #post
  pathoc -n 1 -t 5 -e -p -q  $ip 'post:/audiocontrol.cgi:b"Audio Mute='$r'":h"Authorization"="Basic YWRtaW46YjNZb25kQ2FtZmluaXR5TUtF" ' | tee -a "log_$NOW".txt | tee last_cmd.txt | grep 'HTTP/1.[0-1] 2' &> /dev/null
  ;;  
5)
#long post body
  #####pathoc -t 2 -e -q -p $ip 'post:/audiocontrol.cgi:b@70000,ascii:h"Authorization"="Basic YWRtaW46YjNZb25kQ2FtZmluaXR5TUtF" ' | tee -a $fileName 
  pathoc -n 1 -t 5 -e -p -q  $ip 'post:/audiocontrol.cgi:b@70000,ascii:h"Authorization"="Basic YWRtaW46YjNZb25kQ2FtZmluaXR5TUtF" ' | tee -a "log_$NOW".txt | tee last_cmd.txt | grep 'HTTP/1.[0-1] 2' &> /dev/null
 ;;  
*)
  #post
  pathoc -n 1 -t 5 -e -p -q  $ip 'post:/nightmodecontrol.cgi:b"IRLed='$r'":ir,@5:h"Authorization"="Basic YWRtaW46YjNZb25kQ2FtZmluaXR5TUtF" ' | tee -a "log_$NOW".txt | tee last_cmd.txt | grep 'HTTP/1.[0-1] 2' &> /dev/null
  ;;
esac
 
  
  
  
    
  if [ $? == 0 ]; then
		good=$(( $good+1 ))
		#last_out=$(<last_cmd.txt)
		#echo "$last_out" >> "log_$NOW""_good.txt"
	else
		bad=$(( $bad+1 ))
		grep "HTTP/1.[0-1] 5\|Invalid server response\|Error connecting to" last_cmd.txt
		if [ $? == 0 ]; then

		    last_out=$(<last_cmd.txt)
		    echo "$last_out" >> "log_$NOW""_bad.txt"
		fi    
		
	fi		
	echo -ne "Percent Done: $d  \tGood: $good   \tBad: $bad \r"
 
done



fi #end DLINK fuzzing loop




echo -ne "\n"
ENDTIME=$(date +%s)
rm last_cmd.txt

echo "END OF TESTING" >> "log_$NOW.txt"
echo "Total Tests:$max" >> "log_$NOW.txt"
echo "Elapsed Time: $(($ENDTIME - $STARTTIME)) seconds" >> "log_$NOW.txt"
numTimeouts=$(grep -c "Timeout" "log_$NOW.txt")
echo "Timeouts:$numTimeouts" >> "log_$NOW.txt"
num200=$(grep -c "HTTP/1.[0-1] 200" "log_$NOW.txt")
echo "HTTP 200 Returns:$num200" >> "log_$NOW.txt"
num2xx=$(grep -c "HTTP/1.[0-1] 2[0-9][1-9]" "log_$NOW.txt")
echo "HTTP (non-200) 2XX Returns:$num2xx" >> "log_$NOW.txt"
num300=$(grep -c "HTTP/1.[0-1] 3" "log_$NOW.txt")
echo "HTTP 3XX Returns:$num300" >> "log_$NOW.txt"
num400=$(grep -c "HTTP/1.[0-1] 4" "log_$NOW.txt")
echo "HTTP 4XX Returns:$num400" >> "log_$NOW.txt"
numNull=$(grep -c "(null)" "log_$NOW.txt")
echo "(null) Returns:$numNull" >> "log_$NOW.txt"
num500=$(grep -c "HTTP/1.[0-1] 5" "log_$NOW.txt")
echo "HTTP 5XX Returns:$num500" >> "log_$NOW.txt"

echo ""
tail  --lines=8 "log_$NOW.txt"
echo "Wrote files: log_$NOW.txt, log_$NOW""_bad.txt"
echo "Finished"
echo ""
