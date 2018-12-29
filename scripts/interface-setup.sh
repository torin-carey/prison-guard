#!/bin/bash

IP=/sbin/ip
IPTABLES=/sbin/iptables
NETNS1=prison
NETNS2=guard
TABLE=prisonguard

set -x

case $1 in
start)
	$IP link add veth0 type veth peer name veth1
	$IP link add veth2 type veth peer name veth3
	
	$IP link set dev veth3 up netns $NETNS1
	$IP link set dev veth2 up netns $NETNS2
	$IP link set dev veth1 up netns $NETNS2
	$IP link set dev veth0 up
	
	$IP netns exec $NETNS1 $IP addr add 172.31.1.3/31 dev veth3
	$IP netns exec $NETNS2 $IP addr add 172.31.1.2/31 dev veth2
	$IP netns exec $NETNS2 $IP addr add 172.31.1.1/31 dev veth1
	$IP addr add 172.31.1.0/31 dev veth0
	
	$IP netns exec $NETNS1 $IP route add default via 172.31.1.2
	$IP netns exec $NETNS2 $IP route add default via 172.31.1.0
	$IP route add 172.31.1.2/31 via 172.31.1.1

	$IP netns exec $NETNS2 $IP route add unreachable default table $TABLE
	$IP netns exec $NETNS2 $IP route add 172.31.1.0 via 172.31.1.0 table $TABLE
	$IP netns exec $NETNS2 $IP rule add iif veth2 table $TABLE
	
	$IPTABLES -t nat -A POSTROUTING -s 172.31.1.0/30 -o eth0 -j MASQUERADE
	$IPTABLES -t nat -A POSTROUTING -s 172.31.1.0/30 -o wlan0 -j MASQUERADE
	$IP netns exec $NETNS2 $IPTABLES -t nat -A POSTROUTING -o tun+ -j MASQUERADE
	;;
stop)
	$IPTABLES -t nat -D POSTROUTING -s 172.31.1.0/30 -o eth0 -j MASQUERADE
	$IPTABLES -t nat -D POSTROUTING -s 172.31.1.0/30 -o wlan0 -j MASQUERADE
	$IP netns exec $NETNS2 $IPTABLES -t nat -D POSTROUTING -o tun+ -j MASQUERADE
	;;
esac
