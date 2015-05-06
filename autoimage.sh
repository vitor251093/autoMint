#!/bin/bash

export red='\033[1;31m'
export NC='\033[0m'

#That link is the 'folder' which must contain the following files:
# automint.sh, autowindows.sh, posimagem-mint.sh, checkWeb.sh, index.html, logo_dcc.png, offline.png and online.png
export LoginFilesFolder="http://yourwebsite.com/~youraccount/Imagem"


echo -e "${red}Detecting Windows partition${NC}"
IFS='\n'
partitions=$(cat /proc/partitions)
gramar="[0-9]*[^+]sda[1-9]"
partitions=$(echo $partitions | grep -o $gramar)
gramar="[0-9][0-9][0-9]*"
partitionSize=$(echo $partitions | grep -o $gramar)
partitionSize=$(echo $partitionSize | sort -k1,1n)
partitionSize=$(echo $partitionSize | tail -1)
gramar="$partitionSize[^+]sda[1-9]"
partitions=$(echo $partitions | grep -o $gramar)
gramar="sda[1-9]"
export windowsPartition=$(echo $partitions | grep -o $gramar)
echo -e "${red}Windows partition detected: $windowsPartition${NC}"
IFS=$'\n'


echo -e "${red}Dtecting Windows version...${NC}"
apt-get install -y reglookup
mount /dev/$windowsPartition /mnt
cd /mnt/Windows/System32/config/
if [ -f "software" ]; then
  reg=$(reglookup -p "Microsoft/Windows NT/CurrentVersion/ProductName" software)
else
  reg=$(reglookup -p "Microsoft/Windows NT/CurrentVersion/ProductName" SOFTWARE)
fi
WindowsVersion=$(echo $reg | grep -o 'SZ,[^?]*,')
WindowsVersion=$(echo $WindowsVersion | grep -o ',[^,]*')
WindowsVersion=$(echo $WindowsVersion | grep -o '[^,]*')
if [ -f "system" ]; then
  reg=$(reglookup -p "ControlSet001/Control/Session Manager/Environment/PROCESSOR_ARCHITECTURE" system)
else 
  reg=$(reglookup -p "ControlSet001/Control/Session Manager/Environment/PROCESSOR_ARCHITECTURE" SYSTEM)
fi
WindowsArchitecture=$(echo $reg | grep -o 'SZ,[^?]*,')
WindowsArchitecture=$(echo $WindowsArchitecture | grep -o ',[^,]*')
WindowsArchitecture=$(echo $WindowsArchitecture | grep -o '[^, ]*')
if [[ $WindowsArchitecture == "x86" ]]; then
  export WindowsArchitecture="32-bits"
else
  export WindowsArchitecture="64-bits"
fi
export Windows="Microsoft $WindowsVersion$WindowsArchitecture"
cd ~/
apt-get remove -y reglookup
umount /mnt
echo -e "${red}Windows: $Windows${NC}"


echo -e "${red}Downloading Linux auto-image script...${NC}"
wget "$LoginFilesFolder/automint.sh" -O /root/automint.sh
chmod 755 /root/automint.sh
cd /root
./automint.sh
rm automint.sh


echo -e "${red}Downloading Windows auto-image script...${NC}"
wget "$LoginFilesFolder/autowindows.sh" -O /root/autowindows.sh
chmod 755 /root/autowindows.sh
cd /root
./autowindows.sh
rm autowindows.sh

export LoginFilesFolder=""
