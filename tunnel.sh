#!/bin/bash

#Config your remote side here:
remote_ip=10.42.0.2
remote_port=22

if [ `whoami` != 'root' ]; then echo "YOU ARE NOT ROOT, this number cannot be completed as dialed.  please try your call again."; exit 1; fi

pidfile=/var/run/ppp0.pid
pid=

gateway=$(/sbin/ip route | awk '/default/ { print $3 }')

# trap ctrl-c and signal pppd to shutdown
trap close_conn INT

function close_conn(){
    echo "Closing Connection."
    kill -HUP $pid
}

#pppds "usepeerdns" doesnt work, but adding '-L53:0.0.0.0:53' to ssh hooks does (forwards local port 53(DNS) to remote)
function setup_conn(){
    cd ~/
    echo "Current Gateway " $gateway
    route add $remote_ip gw $gateway
    pppd updetach defaultroute replacedefaultroute usepeerdns noauth passive pty \
        "ssh $remote_ip -p $remote_port -L53:0.0.0.0:53 pppd nodetach notty noauth ms-dns 8.8.8.8" \
        10.0.0.1:10.0.0.2
    pid=`cat $pidfile`
    echo "Public Facing IP " `curl -s 'http://checkip.dyndns.org' |
                              sed 's/.*Current IP Address: \([ 0-9\.\.]*\).*/\1/g'`
}

setup_conn

while ps -p $pid > /dev/null;
do 
    sleep 1;
    printf \
    "\rConnected For: %02d:%02d:%02d:%02d" \
    "$((SECONDS/86400))" "$((SECONDS/3600%24))" "$((SECONDS/60%60))" "$((SECONDS%60))"; 
done

route del $remote_ip gw $gateway
