#!/bin/bash
##written by carlos nikolaus krämer
pidof -o %PPID -x $0 >/dev/null && echo "ERROR: Script $0 already running" && exit 1
airctrl --ipaddr xxx.xxx.xxx.xxx --protocol coap --aqil 0
while :
do
#var0=$(airctrl --ipaddr xxx.xxx.xxx.xxx --protocol coap | grep -o -P 'PM25:\ [0-254]' | cut -c 7-9)
#### trip point: the WHO says https://www.who.int/news-room/fact-sheets/detail/ambient-(outdoor)-air-quality-and-health
var1=7
# grep values from https://github.com/opendata-stuttgart/sensors-software your fine dust sensor
### PM2.5
var2=$(curl -s http://xxx.xxx.xxx.xxx/values | grep -o -P '[0-9].[0-9]&nbsp;µg/m³' | cut -c -3 | sed -n 2p | awk '{print int($1+0.5)}' )
### PM10
var3=$(curl -s http://xxx.xxx.xxx.xxx/values | grep -o -P '[0-9].[0-9]&nbsp;µg/m³' | cut -c -3 | sed -n 1p | awk '{print int($1+0.5)}' )
### Mix up 
var4=$((var2+var3))
### fan
fanspeed=$(airctrl --ipaddr xxx.xxx.xxx.xxx --protocol coap | grep -o -P 'Fan speed:\ [1,2,3,s,t,a]' | cut -c 12 ) &&
#off=$( airctrl --ipaddr xxx.xxx.xxx.xxx --protocol coap --pwr 0 )
#on=$(  airctrl --ipaddr xxx.xxx.xxx.xxx --protocol coap --pwr 1 )
if [ "$((var4))" -lt "$((var1))" ]
	#"$((fanspeed))" = 2 ]
then
    echo "PM $var4 ppm fan state $fanspeed"
    sleep 10
else
    airctrl --ipaddr xxx.xxx.xxx.xxx --protocol coap --mode M --om 3 &&
    sleep 1
    echo "PM $var4 ppm set fan to 3, state $fanspeed"
sleep 120
if [ "$((var4))" -gt "$((var1))" ]
then
    airctrl --ipaddr xxx.xxx.xxx.xxx --protocol coap --mode M --om t &&
sleep 1
echo "PM $var4 ppm set fan to t, state $fanspeed"
    sleep 60
else
    airctrl --ipaddr xxx.xxx.xxx.xxx --protocol coap --mode B &&
	    sleep 1
    echo "PM $var4 ppm set fan to B, state $fanspeed"
    sleep 120
fi
fi
done
