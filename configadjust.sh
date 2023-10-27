#!/bin/bash 

# For this to work, you have to first download my configuration file: file-etc-apcupsd-apcupsd.conf ... that file is used here to copy my config into the correct directory as a functional directive for the app. 
#Without installing the working config file, the script will not work. This is intended as a helper script. You may need to follow some of these steps manually and part of the difficulty with this 
#Is that I was unable to do a completely authentic test run of this as my first successful install was done on bare metal and I ran the commands for that line by line
#However, if you can get sudo apcaccess to render meaningful output, that indicates the program is communicating with the UPS. The script was tested on VirtualBox but the successful
#For all of these scripts, the same version of Ubuntu Jammy Jellyfish was used 

#NOTE: Tested on Ubuntu Jammy Jellyfish
#Ubuntu 22.04.3 LTS
#Kernel: 5.19.0-35-generic



restartdaemon() {
    sudo systemctl restart apcupsd
}


lockremove() {
while :
do
    sudo rm "$(find /var/lock -iname "*LCK*")"
    break
done
}

searchlock=$(find /var/lock -iname "*LCK*")

if { 
     sudo apt-get install apcupsd -y && 
     sudo cp -r /etc/apcupsd/apcupsd.conf /etc/apcupsd/apcupsd.conf.bak &&
     sudo cp -r /home/vagrant/Desktop/apcupsconfig/apcupsd.conf /etc/apcupsd/apcupsd.conf && #NOTE: You can put the config file where you want - but as you can see in my case I used a Vagrant box to test the script 
     sudo sed -i 's/ISCONFIGURED=no/ISCONFIGURED=yes/g' /etc/default/apcupsd &&
     echo Removing lock file in /var/lock
        if  [[ -n "$searchlock" ]]; then
           #if find /var/lock -iname "*LCK*"; then 
            timeout 3 sudo rm /var/lock/LCK*
        fi   
            #sudo systemctl restart apcupsd
    }; then
       echo configs have been modified for the apcupsd daemon
       echo Attempting to start apctest
     if sudo apctest; then
       exit 0
     fi
 else
        echo Are you root? This program must be run with root - please try again
        echo Restarting apcusd daemon - try running again with root or check logs
fi
#NOTE: Test with sudo apcaccess. If the profile menu launches you can be sure the app is working though more tests need to be performed to verify successful integration of all system tools. 
