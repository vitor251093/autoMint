#!/bin/bash

IPV4=$(hostname -I)
if [[ $IPV4 == "" ]]; then
	echo "Ethernet Cable: OFF<BR>" > /tmp/webStatus.log;
	echo "Internal Web: OFF<BR>" >> /tmp/webStatus.log;
	echo "Internet: OFF" >> /tmp/webStatus.log;
else
	echo "Ethernet Cable: ON<BR>" > /tmp/webStatus.log;
	
	#Type your university internal IP (like the NFS mount point) here:
	ping -c 3 <YOUR_UNIVERSITY_INTERNAL_IP> > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Internal Web: OFF<BR>" >> /tmp/webStatus.log;
	else
		echo "Internal Web: ON<BR>" >> /tmp/webStatus.log;
	fi
	
	#Google IP:
	ping -c 3 173.194.119.4 > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Internet: OFF" >> /tmp/webStatus.log;
	else
		echo "Internet: ON" >> /tmp/webStatus.log;
	fi
fi
