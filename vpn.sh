#!/bin/bash

SCRIPT_DIR="/root/.scripts/openVPN"
PROTOCOL="tcp"
PORT="80"
CONFIG_FILE=`ls $SCRIPT_DIR/conf/ | grep $PROTOCOL | grep $PORT | head -n 1`


args=("$@")
n=${#args[@]} 

for (( i=0;i<$n;i++))
	do

	if [ "${args[${i}]}" = "--protocol" ]
		then
		((i++))
		PROTOCOL=${args[${i}]}
		CONFIG_FILE=`ls $SCRIPT_DIR/conf/ | grep $PROTOCOL | grep $PORT | head -n 1`
		continue
	fi
	if [ "${args[${i}]}" = "--port" ]
		then
		((i++))
		PORT=${args[${i}]}
		CONFIG_FILE=`ls $SCRIPT_DIR/conf/ | grep $PROTOCOL | grep $PORT | head -n 1`
		continue
	fi

	if [ "${args[${i}]}" = "--help" -o "${args[${i}]}" = "-h" ]
		then
		echo "vpn: vpn [OPTIONS] [COMMAND]"
		echo "         Start/stop/configure the openVPN connection"
		echo ""
		echo "         Options:"
		echo "            -c, --config  user:pass path/file.zip        configure the openVPN server with the vpnBOOK configuration"
		echo "                                                         user= vpnBOOK's user"
		echo "                                                         pass= vpnBOOK's password"
		echo "                                                         path/file.zip= path to the vpnBOOK configuration zip file"
		echo "            -h, --help                                   show options"
		echo "                --port                                   the port to be used on vpn connection, needs start as command"
		echo "                --protocol                               the protocol to be used on vpn connection, needs start as command"
		echo ""
		echo "         Commands:"
		echo "            start                                        starts the vpn connection"
		echo "            status                                       shows if the service is running ot not"
		echo "            stop                                         stops the vpn connection"
		echo ""
		echo "         Exampls:"
		echo "            vpn --help"
		echo "            vpn -c username:password123 ~/Downloads/VPNbookFR1.zip"
		echo "            vpn --protocol udp --port 53 start"
		echo "            vpn status"
		echo "            vpn stop"
		break

	elif  [ "${args[${i}]}" = "--config" -o "${args[${i}]}" = "-c" ]
		then
		echo $i
		((i++))
		echo $i
		USER=`echo ${args[${i}]} | awk -F ":" '{print $1}'`
		PASS=`echo ${args[${i}]} | awk -F ":" '{print $2}'`
		rm -rf $SCRIPT_DIR/conf/*
		echo "$USER" > $SCRIPT_DIR/conf/auth.vpn
		echo "$PASS" >> $SCRIPT_DIR/conf/auth.vpn
		((i++))
		echo "Unziping `echo ${args[${i}]} | awk -F "/" '{print $NF}'`"
		unzip ${args[${i}]} -d $SCRIPT_DIR/conf
		break

	elif  [ "${args[${i}]}" = "status" ]
		then
		PID=`pidof openvpn`
		if [ -z $PID ]
			then
			echo -e "OpenVPN is not running: \e[31m● inactive\e[0m"
		else
			echo -e "OpenVPN is running on proccess:$PID \e[32m● active\e[0m"
		fi
		break

	elif  [ "${args[${i}]}" = "start" ]
		then
		echo -e "Using \e[32m$CONFIG_FILE\e[0m as a configuration file."
		openvpn --config $SCRIPT_DIR/conf/$CONFIG_FILE --auth-user-pass $SCRIPT_DIR/conf/auth.vpn &
		break

	elif  [ "${args[${i}]}" = "stop" ]
		then
		PID=`pidof openvpn`
		if [ -z $PID ]
			then
			echo -e "OpenVPN is not running: \e[31m● inactive\e[0m"
		else
			echo "killing process: $PID"
			kill $PID &
		fi
		break

	else
		vpn --help
		break
	fi
done


