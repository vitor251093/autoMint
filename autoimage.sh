#!/bin/bash

activateNFS='NO'
activateLDAP='NO'
activateBURG='YES'
activateGuest='NO'
activateMySQL='NO'
activateTheme='YES'
activateWindows='NO'
activateAutoShutdown='NO'

while [ "$1" != "" ]; do
    case $1 in
        -nfs )                  activateNFS='YES'
                                shift
                                NFShome=$1
                                ;;
        -ldap )                 activateLDAP='YES'
        			shift
                                LDAPbase=$1
                                shift
                                LDAPuri=$1
                                ;;
        -g | -guest )           activateGuest='YES'
                                ;;
        -mysql )                activateMySQL='YES'
                                ;;
        -nT | --no-theme )      activateTheme='NO'
                                ;;
        -nB | --no-burg )       activateBURG='NO'
                                ;;
        -w | -windows )         activateWindows='YES'
                                ;;
        -h | -s | -shutdown )   activateAutoShutdown='YES'
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

red='\033[1;31m'
NC='\033[0m'

if [[ $activateBURG == "YES" ]]; then
	echo -e "${red}Type BURG password:${NC}"
	read -s BURG_PASSWORD
	
	echo -e "${red}Type BURG password again:${NC}"
	read -s BURG_PASSWORD_CONFIRM
	
	while [ "$BURG_PASSWORD" != "$BURG_PASSWORD_CONFIRM" ]; do
    		echo -e "${red}Password don't match${NC}"
		
    		echo -e "${red}Type BURG password:${NC}"
    		read -s BURG_PASSWORD
		
    		echo -e "${red}Type BURG password again:${NC}"
    		read -s BURG_PASSWORD_CONFIRM
	done
fi


if [[ $activateMySQL == "YES" ]]; then
	echo -e "${red}Type MySQL password:${NC}"
	read -s MySQL_PASSWORD
	
	echo -e "${red}Type MySQL password again:${NC}"
	read -s MySQL_PASSWORD_CONFIRM
	
	while [ "$MySQL_PASSWORD" != "$MySQL_PASSWORD_CONFIRM" ]; do
    		echo -e "${red}Password don't match${NC}"
		
    		echo -e "${red}Type MySQL password:${NC}"
    		read -s MySQL_PASSWORD

    		echo -e "${red}Type MySQL password again:${NC}"
    		read -s MySQL_PASSWORD_CONFIRM
	done
fi


#The following folder is the online path where you will download these files: 
#checkWeb.sh, index.html, logo.png, offline.png, online.png and posimage.sh
LoginFilesFolder="http://university.website/~your_account/Image_files"
Message1="educationalMint was created by VitorMM,"
Message2="but it's Creative Commons, so it's yours."

echo -e "${red}Getting Linux distribution...${NC}"
LinuxVersion=$(lsb_release -d -s)
LinuxArchitecture=$(getconf LONG_BIT)
Linux="$LinuxVersion $LinuxArchitecture-bits"
echo -e "${red}Linux: $Linux${NC}"

if [[ $activateWindows == "YES" ]]; then
	echo -e "${red}Getting Windows partition...${NC}"
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
	windowsPartition=$(echo $partitions | grep -o $gramar)
	echo -e "${red}Windows partition found: $windowsPartition${NC}"
	IFS=$'\n'
	
	echo -e "${red}Getting Windows version...${NC}"
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
  		WindowsArchitecture="32-bits"
	else
  		WindowsArchitecture="64-bits"
	fi
	Windows="Microsoft $WindowsVersion$WindowsArchitecture"
	cd ~/
	apt-get remove -y reglookup
	umount /mnt
	echo -e "${red}Windows: $Windows${NC}"
fi


echo -e "${red}Updating bash to avoid vulnerabilities...${NC}"
echo -e "${red}-> Updating repositories list...${NC}"
apt-get update -qq
echo -e "${red}-> Installing package...${NC}"
apt-get install --only-upgrade bash


if [[ $activateTheme == "YES" ]]; then
	echo -e "${red}Configuring Login Screen...${NC}"
	sed -i '/\[daemon\]/aSelectLastLogin=false' /etc/mdm/mdm.conf
	sed -i '/\[daemon\]/aGreeter=/usr/lib/mdm/mdmwebkit' /etc/mdm/mdm.conf
	sed -i '/\[greeter\]/aHTMLTheme=Simple' /etc/mdm/mdm.conf
	
	cd /usr/share/mdm/html-themes
 	cp -R Zukitwo-Circle/ Simple/
 	cd Simple/
 	wget "$LoginFilesFolder/index.html" -O index.html
 	cd img/
 	wget "$LoginFilesFolder/logo.png" -O logo.png
 	wget "$LoginFilesFolder/offline.png" -O offline.png
 	wget "$LoginFilesFolder/online.png" -O online.png
 	
 	sed -i 's/Zukitwo-Circle/Simple/g' /usr/share/mdm/html-themes/SimpleDCC/theme.info
 	sed -i 's/Zukitwo Circle by Bernard/Simple by VitorMM/g' /usr/share/mdm/html-themes/SimpleDCC/theme.info
	
 	wget "$LoginFilesFolder/checkWeb.sh" -O /etc/checkWeb.sh
 	chmod 755 /etc/checkWeb.sh
 	echo '@reboot root /etc/checkWeb.sh' >> /etc/crontab
 	echo '*/1 * * * * root /etc/checkWeb.sh' >> /etc/crontab
fi


if [[ $activateNFS == "YES" ]]; then
	echo -e "${red}NFS - Configuring home mounting...${NC}"
	apt-get install -y nfs-common
	echo -e '$NFShome:/home\t/home\tnfs\tnfsvers=3,soft\t0\t0' >> /etc/fstab
fi


if [[ $activateLDAP == "YES" ]]; then
	echo -e "${red}LDAP - Configuring students login...${NC}"
	echo -e 'BASE\t$LDAPbase\nURI\t$LDAPuri' >> /etc/ldap/ldap.conf
	echo -e 'passwd:         compat ldap' >> /etc/nsswitch.conf
	echo -e 'group:          compat ldap' >d> /etc/nsswitch.conf
	echo -e 'shadow:         compat ldap' >> /etc/nsswitch.conf
	DEBIAN_FRONTEND=noninteractive apt-get install -q -y libnss-ldapd libpam-ldapd nscd
	head -n -2 /etc/ldap/ldap.conf > /etc/ldap/ldap2.conf
	rm /etc/ldap/ldap.conf
	mv /etc/ldap/ldap2.conf /etc/ldap/ldap.conf
	
	echo -e "${red}Changing nslcd.conf permissions to avoid vulnerabilities...${NC}"
	chmod 711 /etc/nslcd.conf
fi


if [[ $activateBURG == "YES" ]]; then
	echo -e "${red}Installing BURG...${NC}"
	echo -e "${red}-> Adding repository...${NC}"
	echo "burg-pc burg/linux_cmdline string" | debconf-set-selections
	echo "burg-pc burg/linux_cmdline_default string quiet splash vga=791" | debconf-set-selections
	echo "burg-pc burg-pc/install_devices multiselect ${DEVICE}" | debconf-set-selections
	add-apt-repository -y ppa:n-muench/burg
	echo -e "${red}-> Updating repositories list...${NC}"
	apt-get update -qq
	echo -e "${red}-> Installing packages...${NC}"
	apt-get install -y burg burg-themes
	burg-install "(hd0)"
	
	
	echo -e "${red}Configuring BURG...${NC}"
	
	echo -e "${red}-> Configuring BURG Layout...${NC}"
	echo -e "${red}-> Disabling unneeded buttons...${NC}"
	for i in {18..29}
	do
   		sed -i "$i s/^/#/" /boot/burg/themes/sora/menus
	done
	for i in {40..44}
	do
   		sed -i "$i s/^/#/" /boot/burg/themes/sora/menus
	done
	echo -e "${red}-> Removing About window lines...${NC}"
	for i in {73..81}
	do
   		sed -i "$i s/^/#/" /boot/burg/themes/sora/menus
	done
	echo -e "${red}-> Adding About window new lines...${NC}"
	sed -i "72itext { text = \"Auto-Generated image for Linux Mint\" class = \"dialog-text\" }" /boot/burg/themes/sora/menus
	sed -i "73itext { class = br }" /boot/burg/themes/sora/menus
	sed -i "74itext { text = \"$Linux\" class = \"dialog-text\" }" /boot/burg/themes/sora/menus
	if [[ $activateWindows == "YES" ]]; then
		sed -i "75itext { text = \"$Windows\" class = dialog-text }" /boot/burg/themes/sora/menus
	else
		sed -i "75i " /boot/burg/themes/sora/menus
	fi
	sed -i "76itext { class = br }" /boot/burg/themes/sora/menus
	sed -i "77itext { text = \"$Message1\" class = dialog-text\$ }" /boot/burg/themes/sora/menus
	sed -i "78itext { text = \"$Message2\" class = dialog-text\$ }" /boot/burg/themes/sora/menus
	sed -i 's/txt-about.png/txt-help.png/g' /boot/burg/themes/sora/menus
	
	
	echo -e "${red}-> Improving Sora Interface...${NC}"
	sed -i "6 s/^/#/" /boot/burg/themes/sora/theme
	sed -i "6ibackground = \":,,black,#0\"" /boot/burg/themes/sora/theme
	for i in {82..90}
	do
   		sed -i "$i s/^/#/" /boot/burg/themes/sora/theme
	done
	
	
	echo -e "${red}-> Configuring BURG hotkeys...${NC}"
	cd /boot/burg/themes/conf.d/
	echo -e 'onkey {\n  c = "*menu_popup term_window"\n  f1 = "menu_popup about"\n  f9 = halt\n  f10 = reboot\n}\n\n' > 10_hotkey
	echo -e 'mapkey {\n  f5 = ctrl-x\n}' >> 10_hotkey
	
	
	echo -e "${red}-> Definning BURG parameters...${NC}"
	gramar='#*GRUB_TIMEOUT=[^*?]*'
	GRUB_TIMEOUT=$(cat /etc/default/burg | grep -o $gramar)
	sed -i "s/$GRUB_TIMEOUT/GRUB_TIMEOUT=120/g" /etc/default/burg
	
	gramar='#*GRUB_DISABLE_LINUX_RECOVERY=[^*?]*'
	GRUB_DISABLE_LINUX_RECOVERY=$(cat /etc/default/burg | grep -o $gramar)
	sed -i "s/$GRUB_DISABLE_LINUX_RECOVERY/GRUB_DISABLE_LINUX_RECOVERY=\"true\"/g" /etc/default/burg
	
	gramar='#*GRUB_THEME=[^*?]*'
	GRUB_THEME=$(cat /etc/default/burg | grep -o $gramar)
	sed -i "s/$GRUB_THEME/GRUB_THEME=\"sora\"/g" /etc/default/burg
	
	gramar='#*GRUB_GFXMODE=[auto,saved0123456789x]*'
	GRUB_GFXMODE=$(cat /etc/default/burg | grep -o $gramar)
	BEST_RESOLUTIONS="1280x960,1280x800,1280x720,1024x768,1024x640,1024x576,960x720,960x540,800x600,640x480"
	sed -i "s/$GRUB_GFXMODE/GRUB_GFXMODE=$BEST_RESOLUTIONS/g" /etc/default/burg
	
	echo -e 'GRUB_USERS="ubuntu=:windows="' >> /etc/default/burg
	
	
	echo -e "${red}-> Setting BURG password...${NC}"
	echo -e "$BURG_PASSWORD\n$BURG_PASSWORD" | burg-adduser -s root
	update-burg
fi


echo -e "${red}Installing packages...${NC}"
apt-get install -y curl emacs gcc g++ geany git kate konsole kile mercurial flex bison byacc libopencv-dev scilab-sivp axiom
apt-get install -y cmake cmake-curses-gui cmake-qt-gui libmpfr-dev libgmp3-dev libmpfi-dev libboost-all-dev libcgal-dev octave
apt-get install -y vim scilab libreoffice vlc firefox gimp inkscape p7zip-full blender wireshark netbeans audacity keepassx
apt-get install -y codeblocks qtcreator qt-sdk phonon-backend-gstreamer geogebra ruby postgresql pgadmin3 r-base maxima --fix-missing
apt-get install -y idle-python2.7 idle-python3.4 openssh-client openssh-server


if [[ $activateMySQL == "YES" ]]; then
	echo -e "${red}Installing MySQL...${NC}"
	debconf-set-selections <<< 'mysql-server mysql-server/root_password password $MySQL_PASSWORD'
	debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password $MySQL_PASSWORD'
	apt-get install -y mysql-server mysql-client mysql-workbench php5-mysql --fix-missing
fi


echo -e "${red}Installing Atom...${NC}"
echo -e "${red}-> Adding repository...${NC}"
add-apt-repository -y ppa:webupd8team/atom
echo -e "${red}-> Updating repositories list...${NC}"
apt-get update -qq
echo -e "${red}-> Installing package...${NC}"
apt-get install atom --fix-missing


echo -e "${red}Installing Intellij IDEA...${NC}"
echo -e "${red}-> Getting download link...${NC}"
cd /tmp
gramar="versionIDEALong[^*]*;"
ideaVar=$(wget --quiet -O - http://www.jetbrains.com/js2/version.js?ver=291009 | grep -o $gramar)
gramar='\"[^\"]*\"'
ideaVar=$(echo $ideaVar | grep -o $gramar)
ideaVar=${ideaVar//\"}
ideaFile="http://download.jetbrains.com/idea/ideaIC-$ideaVar.tar.gz"
echo -e "${red}-> Downloading Intellij IDEA...${NC}"
wget $ideaFile -O idea-IC.tar.gz
echo -e "${red}-> Extracting Intellij IDEA...${NC}"
tar xvf idea-IC.tar.gz
echo -e "${red}-> Moving Intellij IDEA...${NC}"
ideaFile=$(find /tmp -maxdepth 1 -name "idea-IC-*")
sudo mv $ideaFile /opt/idea-IC
cd /opt
echo -e "${red}-> Setting permissions...${NC}"
sudo chown -R root:root idea-IC
sudo chmod -R +r idea-IC
echo -e "${red}-> Creating shortcuts...${NC}"
sudo touch /usr/bin/idea-IC
sudo chmod 775 /usr/bin/idea-IC
echo -e '#!/bin/sh\n' > /usr/bin/idea-IC
echo -e 'export INTELLIJ_IDEA_HOME="/opt/idea-IC"\n\n' >> /usr/bin/idea-IC
echo -e '$INTELLIJ_IDEA_HOME/bin/idea.sh $*' >> /usr/bin/idea-IC
echo -e "${red}-> Criando atalho no menu...${NC}"
echo -e '[Desktop Entry]\n' > /usr/share/applications/idea-IC.desktop
echo -e 'Encoding=UTF-8\n' >> /usr/share/applications/idea-IC.desktop
echo -e 'Type=Application\n' >> /usr/share/applications/idea-IC.desktop
echo -e 'Terminal=false\n' >> /usr/share/applications/idea-IC.desktop
echo -e 'Name=Intellij IDEA\n' >> /usr/share/applications/idea-IC.desktop
echo -e 'Comment=Work Miracles in Java and Beyond\n' >> /usr/share/applications/idea-IC.desktop
echo -e 'Exec=idea-IC\n' >> /usr/share/applications/idea-IC.desktop
echo -e 'Icon=/opt/idea-IC/bin/idea.png\n' >> /usr/share/applications/idea-IC.desktop
echo -e 'Categories=GTK;Development;IDE;\n' >> /usr/share/applications/idea-IC.desktop
echo -e 'StartupNotify=true' >> /usr/share/applications/idea-IC.desktop


echo -e "${red}Installing Google Chrome...${NC}"
echo -e "${red}-> Adding repository...${NC}"
sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo -e "${red}-> Updating repositories list...${NC}"
apt-get update -qq
echo -e "${red}-> Installing package...${NC}"
apt-get install -y google-chrome-stable


echo -e "${red}Installing Free Pascal e Lazarus...${NC}"
echo -e "${red}-> Getting Lazarus webpage...${NC}"
gramar="/projects/lazarus/files/Lazarus%20Linux%20i386%20DEB/Lazarus%20[^/]*"
lazaruslink=$(wget --quiet -O - http://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20i386%20DEB/ | grep -o $gramar)
IFS=$' '
lazaruslink="sourceforge.net${lazaruslink[0]}"
lazaruslink=$(echo $lazaruslink|head -n 1)
echo -e "${red}-> Getting Lazarus download link...${NC}"
gramar="$lazaruslink/lazarus_[^?]*.deb"
lazarusPageLink=$(wget --quiet -O - $lazaruslink | grep -o $gramar)
lazarusPageLink="${lazarusPageLink/sourceforge.net/ufpr.dl.sourceforge.net}"
lazarusPageLink="${lazarusPageLink/projects/project}"
lazarusPageLink="${lazarusPageLink/files\//}"
lazarusPageLink="http://$lazarusPageLink"
echo -e "${red}-> Getting Free Pascal Source download link...${NC}"
gramar="$lazaruslink/fpc-src_[^?]*.deb"
fpcSrcPageLink=$(wget --quiet -O - $lazaruslink | grep -o $gramar)
fpcSrcPageLink="${fpcSrcPageLink/sourceforge.net/ufpr.dl.sourceforge.net}"
fpcSrcPageLink="${fpcSrcPageLink/projects/project}"
fpcSrcPageLink="${fpcSrcPageLink/files\//}"
fpcSrcPageLink="http://$fpcSrcPageLink"
echo -e "${red}-> Getting Free Pascal download link...${NC}"
gramar="$lazaruslink/fpc_[^?]*.deb"
fpcPageLink=$(wget --quiet -O - $lazaruslink | grep -o $gramar)
fpcPageLink="${fpcPageLink/sourceforge.net/ufpr.dl.sourceforge.net}"
fpcPageLink="${fpcPageLink/projects/project}"
fpcPageLink="${fpcPageLink/files\//}"
fpcPageLink="http://$fpcPageLink"
echo -e "${red}-> Creating work folder...${NC}"
mkdir /etc/lazarus
cd /etc/lazarus
echo -e "${red}-> Downloading Lazarus...${NC}"
wget $lazarusPageLink -O lazarus.deb
echo -e "${red}-> Downloading Free Pascal Source...${NC}"
wget $fpcSrcPageLink -O fpcSrc.deb
echo -e "${red}-> Downloading Free Pascal...${NC}"
wget $fpcPageLink -O fpc.deb
echo -e "${red}-> Installing packages (first try)...${NC}"
sudo dpkg -i *.deb
echo -e "${red}-> Repairing possible error...${NC}"
apt-get -f install -y
echo -e "${red}-> Installing packages again...${NC}"
sudo dpkg -i *.deb
echo -e "${red}-> Removing installation files...${NC}"
rm *.deb
IFS=$'\n'


echo -e "${red}Installing Eclipse...${NC}"
echo -e "${red}-> Getting download link...${NC}"
cd /tmp
gramar='www.eclipse.org/downloads/download.php?file=/technology/epp/downloads/release/[^"]*/eclipse-jee[^"]*gtk.tar.gz'
eclipselink=$(wget --quiet -O - http://eclipse.org/downloads/ | grep -o $gramar)
eclipselink+='&mirror_id=576'
eclipselink=$(echo $eclipselink|tr -d '\n')
eclipsepage=$(wget -qO- $eclipselink)
eclipselink=$(echo $eclipsepage | grep -o 'http://eclipse.c3sl.ufpr.br[^"]*gtk.tar.gz')
IFS=$'\n'
echo -e "${red}-> Downloading Eclipse...${NC}"
wget $eclipselink[0] -O eclipse.tar.gz
echo -e "${red}-> Extracting Eclipse...${NC}"
tar xvf eclipse.tar.gz
echo -e "${red}-> Moving Eclipse...${NC}"
mv eclipse /opt/
cd /opt
echo -e "${red}-> Setting permissions...${NC}"
chown -R root:root eclipse
chmod -R +r eclipse
echo -e "${red}-> Creating bash shortcut...${NC}"
touch /usr/bin/eclipse
chmod 775 /usr/bin/eclipse
echo -e '#!/bin/sh\n' > /usr/bin/eclipse
echo -e 'export ECLIPSE_HOME="/opt/eclipse"\n\n' >> /usr/bin/eclipse
echo -e '$ECLIPSE_HOME/eclipse $*' >> /usr/bin/eclipse
echo -e "${red}-> Creating menu shortcut...${NC}"
echo -e '[Desktop Entry]\n' > /usr/share/applications/eclipse.desktop
echo -e 'Encoding=UTF-8\n' >> /usr/share/applications/eclipse.desktop
echo -e 'Name=Eclipse\n' >> /usr/share/applications/eclipse.desktop
echo -e 'Comment=Eclipse IDE\n' >> /usr/share/applications/eclipse.desktop
echo -e 'Exec=eclipse\n' >> /usr/share/applications/eclipse.desktop
echo -e 'Icon=/opt/eclipse/icon.xpm\n' >> /usr/share/applications/eclipse.desktop
echo -e 'Terminal=false\n' >> /usr/share/applications/eclipse.desktop
echo -e 'Type=Application\n' >> /usr/share/applications/eclipse.desktop
echo -e 'Categories=GNOME;Application;Development;\n' >> /usr/share/applications/eclipse.desktop
echo -e 'StartupNotify=true' >> /usr/share/applications/eclipse.desktop
echo -e "${red}-> Installing dependency...${NC}"
apt-get install -y openjdk-7-jdk


echo -e "${red}Installing SWI-Prolog...${NC}"
echo -e "${red}-> Adding repository...${NC}"
apt-add-repository -y ppa:swi-prolog/stable
echo -e "${red}-> Updating repositories list...${NC}"
apt-get update -qq
echo -e "${red}-> Installing dependencies...${NC}"
apt-get install -y autoconf curl chrpath libunwind8-dev libjpeg-dev unixodbc-dev libreadline-dev libxpm-dev 
apt-get install -y libxt-dev libarchive-dev libossp-uuid-dev ncurses-dev 
apt-get install -y build-essential libssl-dev openjdk-7-jdk
apt-get install -y zlib1g-dev pkg-config libxft-dev libxinerama-dev libice-dev libxext-dev junit libgmp-dev
echo -e "${red}-> Installing package...${NC}"
apt-get install -y swi-prolog


echo -e "${red}Installing Google Earth...${NC}"
if [[ $LinuxArchitecture == "64" ]]; then
         echo -e "${red}-> Adding repository...${NC}"
         dpkg --add-architecture i386
         echo -e "${red}-> Updating repositories list...${NC}"
         apt-get update -qq
         echo -e "${red}-> Installing dependencies...${NC}"
         apt-get install ia32-libs
         echo -e "${red}-> Installing package...${NC}"
         apt-get install googleearth-package
         apt-get install google-earth-stable:i386
else
         echo -e "${red}-> Baixando Google Earth...${NC}"
         wget -O google-earth32.deb http://dl.google.com/dl/earth/client/current/google-earth-stable_current_i386.deb
         echo -e "${red}-> Installing package (first try)...${NC}"
         dpkg -i google-earth32.deb
         echo -e "${red}-> Repairing possible error...${NC}"
         apt-get -f install -y
         echo -e "${red}-> Installing package again...${NC}"
         dpkg -i google-earth32.deb
         echo -e "${red}-> Removing temporary files...${NC}"
         rm google-earth32.deb
fi


echo -e "${red}Updating everything...${NC}"
aptitude -q update
aptitude -q safe-upgrade -y
burg-install /dev/sda
update-burg


if [[ $activateGuest == "YES" ]]; then
	echo -e "${red}Creating Guest user...${NC}"
	echo -e "${red}-> Creating Guest folder...${NC}"
	if [ -d /convidado ]; then
		rm -R /guest
		mkdir /guest
	else
		mkdir /guest
	fi
	
	if [ -z "$(getent passwd guest)" ]; then
		echo -e "${red}-> Adding Guest user...${NC}"
		useradd -d /guest -s /bin/bash guest
	else
		echo -e "${red}-> Modifying Guest user...${NC}"
		usermod -d /guest -s /bin/bash guest
	fi
		echo -e "${red}-> Setting permissions...${NC}"
		chmod 755 -R /guest
		chown -R guest:guest /guest
		echo -e "${red}-> Setting password...${NC}"
		echo -e "guest\nguest" | passwd guest


	echo -e "${red}Inserting cleaning script...${NC}"
	echo -e 'rm -R /guest\nmkdir /guest\nchmod 755 -R /guest\n' > /root/cleaningScript.sh
	echo -e 'chown -R guest:guest /guest' >> /root/cleaningScript.sh
	echo '@reboot root /root/cleaningScript.sh' >> /etc/crontab
	chmod +x /root/cleaningScript.sh
fi


if [[ $activateAutoShutdown == "YES" ]]; then
	echo -e "${red}Inserting auto-shutdown script...${NC}"
	echo -e '55 23\t* * *\troot\tshutdown -h +5' >> /etc/crontab
fi


echo -e "${red}Downloading posimage.sh script...${NC}"
wget "$LoginFilesFolder/posimage.sh" -O /root/posimage.sh
chmod 755 /root/posimage.sh
