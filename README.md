# educationalMint
Script to transform raw installation of Linux Mint into a complete Mint pack for universities and colleges. With it, creating images for the university computer (and for the students) will be very simple. Just download that file and run the following command in it:
  chmod 755 autoimage.sh

Now you can run it (do it as root):
  sudo ./autoimage.sh

# Flags

  -nfs
  
    Will install NFS in the machine, that can be used to mount a home folder. Follow that flag with the home directory (Example: -nfs myhome.university.org).
    
  -ldap
  
    Will install LDAP in the machine, that can be used to do authentication in a server. Follow that flags with LDAP BASE and the LDAP URI (Example: -ldap dc=university,dc=org ldap://ldap.university.org/).
    
  -g | -guest
  
    Will add a Guest user in the machine, just in case you need to run any app and you don't have internet in the moment. The user is 'guest' and the password is also 'guest'.
    
  -mysql
  
    Will install MySQL in the machine. The script will ask for a password just in the beggining of the execution.
    
  -nT | --no-theme
  
    Won't change the login screen. My script create an alternative version of the HTML theme 'Zukitwo-Circle' called 'Simple' which is perfect if you are using NFS and LDAP, but it's also good if just need a login system where the user names are confidential.
    
  -nB | --no-burg
  
    Won't install BURG. BURG will replace GRUB with a very user-friendly intro in your computer, which can be much more receptable to people which don't have much contact with Linux.
    
  -w | -windows
  
    Only make any difference if you use BURG. If you have a Windows in a different partition, that script will add the Windows details (Example: Windows 7 Professional SP1) to your BURG help window, which might be helpful in some cases.
    
  -h | -s | -shutdown
  
    Will add an auto-shutdown script to crontab, which will turn off the machine at midnight. Very useful if it's going to be used in an university to save power.

# Apps
That script include the automatic installation of the following packages throw apt-get:
* curl
* emacs
* gcc
* g++
* geany
* git
* kate
* konsole
* kile
* mercurial
* flex
* bison
* byacc
* libopencv-dev
* scilab-sivp
* axiom
* cmake
* cmake-curses-gui
* cmake-qt-gui
* libmpfr-dev
* libgmp3-dev
* libmpfi-dev
* libboost-all-dev
* libcgal-dev
* octave
* vim
* scilab
* libreoffice
* vlc
* firefox
* gimp
* inkscape
* p7zip-full
* blender
* wireshark
* netbeans
* audacity
* keepassx
* codeblocks
* qtcreator
* qt-sdk
* phonon-backend-gstreamer
* geogebra
* ruby
* postgresql
* pgadmin3
* r-base
* maxima
* idle-python2.7
* idle-python3.4
* openssh-client
* openssh-server

That script has procedures that can automatically install the following apps:
* MySQL (optional)
* Atom
* Intellij IDEA
* Google Chrome
* Free Pascal
* Lazarus
* Eclipse JEE
* SWI-Prolog
* Google Earth
