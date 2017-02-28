#!/bin/bash 

WORKING_DIR="./.multitor" 
PROXIES_FILE="./socks_list.txt"

#IP="127.0.0.1"
IP="10.211.55.16"

mkdir -p $WORKING_DIR
killall -9 tor 
truncate -s 0 $PROXIES_FILE

function get_random_port {
    read LOWERPORT UPPERPORT < /proc/sys/net/ipv4/ip_local_port_range
    while :
	do
    	    PORT="`shuf -i $LOWERPORT-$UPPERPORT -n 1`"
    	    ss -lpn | grep -q ":$PORT " || break
    done
    echo $PORT
}

function template_config { #first arg is port, second - directory postfix
    echo "SOCKSPort $IP:$1"
    DIR="$WORKING_DIR/tor$2"
    echo "DataDirectory $DIR"
    mkdir -p $DIR
    echo "ExitNodes {de}"
    echo "StrictNodes 1" 
}

for sequence in `seq 0 $1`; do 
    CONFIG_FILE=`mktemp -p $WORKING_DIR`
    #echo $CONFIG_FILE
    port=$(get_random_port)
    template_config $port $sequence > $CONFIG_FILE
    echo "$IP:$port" >> $PROXIES_FILE
    tor -f $CONFIG_FILE > $WORKING_DIR/log.tor.$sequence.log & 
done 