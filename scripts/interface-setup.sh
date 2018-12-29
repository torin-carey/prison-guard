#!/bin/bash

IP=/sbin/ip
IPTABLES=/sbin/iptables
NETNS1=prison
NETNS2=guard
TABLE=prisonguard


VETH=(veth-host veth-ghost veth-gpris veth-pris)
HOSTGUARD=(172.31.1.0 172.31.1.1 31)
GUARDPRISON=(172.31.1.2 172.31.1.3 31)

set -x

case $1 in
prison-ns-start)
	/bin/mkdir -p /var/run/netns
	/usr/bin/touch /var/run/netns/prison || true
	/bin/mount --bind /proc/self/ns/net /var/run/netns/prison
	$IP link set lo up
	;;
prison-ns-stop)

	;;
guard-ns-start)

	;;
guard-ns-stop)

	;;
start)
	set -e
	$IP link add ${VETH[0]} type veth peer name ${VETH[1]}
	$IP link add ${VETH[2]} type veth peer name ${VETH[3]}
	
	$IP link set dev ${VETH[3]} up netns $NETNS1
	$IP link set dev ${VETH[2]} up netns $NETNS2
	$IP link set dev ${VETH[1]} up netns $NETNS2
	$IP link set dev ${VETH[0]} up
	
	$IP netns exec $NETNS1 $IP addr add ${GUARDPRISON[1]}/${GUARDPRISON[2]} dev ${VETH[3]}
	$IP netns exec $NETNS2 $IP addr add ${GUARDPRISON[0]}/${GUARDPRISON[2]} dev ${VETH[2]}
	$IP netns exec $NETNS2 $IP addr add ${HOSTGUARD[1]}/${HOSTGUARD[2]} dev ${VETH[1]}
	$IP addr add ${HOSTGUARD[0]}/${HOSTGUARD[2]} dev ${VETH[0]}
	
	$IP netns exec $NETNS1 $IP route add default via ${GUARDPRISON[0]}
	$IP netns exec $NETNS2 $IP route add default via ${HOSTGUARD[0]}
	$IP route add ${GUARDPRISON[0]}/${GUARDPRISON[2]} via ${HOSTGUARD[1]}

	$IP netns exec $NETNS2 $IP route add unreachable default table $TABLE
	$IP netns exec $NETNS2 $IP route add ${HOSTGUARD[0]} via ${HOSTGUARD[0]} table $TABLE
	$IP netns exec $NETNS2 $IP rule add iif ${VETH[2]} table $TABLE
	
	$IPTABLES -t nat -A POSTROUTING -s ${HOSTGUARD[1]} -j MASQUERADE
	$IP netns exec $NETNS2 $IPTABLES -t nat -A POSTROUTING -o tun+ -j MASQUERADE
	;;
stop)
	$IPTABLES -t nat -D POSTROUTING -s ${HOSTGUARD[1]} -j MASQUERADE
	$IP netns exec $NETNS2 $IPTABLES -t nat -D POSTROUTING -o tun+ -j MASQUERADE
	;;
esac
