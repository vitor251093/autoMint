#!/bin/bash

red='\033[1;31m'
NC='\033[0m'

echo -e "${red}Reconfiguring BURG...${NC}"
burg-install /dev/sda
update-burg

echo -e "${red}Adjusting clock...${NC}"
apt-get install ntp -y
# Find the pools that suits you the most in http://www.pool.ntp.org/en/
sed -i 's/server 0.ubuntu.pool.ntp.org/server 1.br.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 1.ubuntu.pool.ntp.org/server 1.south-america.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 2.ubuntu.pool.ntp.org/server 0.south-america.pool.ntp.org/g' /etc/ntp.conf
sed -i 's/server 3.ubuntu.pool.ntp.org/server 0.pool.ntp.org/g' /etc/ntp.conf
/etc/init.d/ntp stop
ntpdate pool.ntp.org
/etc/init.d/ntp start
hwclock -w
