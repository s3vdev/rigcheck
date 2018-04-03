#!/bin/bash

# Originally from repository: https://bitbucket.org/defib/rigcheck/src/master/
# @sixfourtysword

## Usage: put this shell script in the same folder as rigcheck.sh, it will copy that to each ethos machine in ethoservers

##
# Sven Mielke (march 2018) http://bitbucket.org/s3v3n/rigcheck
#
# UPDATE: To prevent passwort input flood, just install "sshpass" (https://gist.github.com/arunoda/7790979), and edit your login details below.
# @mac OS X: brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
# @Linux: apt-get update && apt-get install install sshpass
#
##

##
# Insert IP addressess for your Ethos Rigs. CHANGE THESE EXAMPLES
ethoservers=(
#"192.168.1.1"
#"192.168.1.2"
#"192.168.1.3"
)

##
# ethOS Username
user="ethos";

##
# ethOS Password
pass="live";


RedEcho(){ echo -e "$(tput setaf 1)$1$(tput sgr0)"; }
GreenEcho(){ echo -e "$(tput setaf 2)$1$(tput sgr0)"; }
YellowEcho(){ echo -e "$(tput setaf 3)$1$(tput sgr0)"; }

Index=0
copyConfig=0

##
# Ask for file to copy
#echo "Please enter the file that you would like to transfer to your ethOS rigs, followed by [ENTER]:"
#read file

#read reboot_max_restarts

echo "";
GreenEcho "Do you want to copy the rigcheck_config.sh file to your rigs as well?";
select yn in "Yes" "No"; do
    case $yn in
        Yes )

        copyConfig=1

        break;;
        No )break;;
    esac
done

for sname in "${ethoservers[@]}"
do

    ##
	# This one copies the rigcheck script
	sshpass -p ${pass} scp ./rigcheck.sh ${user}@$sname:/home/ethos/

    ##
    # This one set chmod 755 to rigcheck.sh
	sshpass -p${pass} ssh ${user}@$sname chmod a+x /home/ethos/rigcheck.sh


	##
	# Uncomment this when you are installing the first time/updating the config file
	if [ "${copyConfig}" = "1" ]; then
	    sshpass -p ${pass} scp ./rigcheck_config.sh ethos@$sname:/home/ethos/
	    sshpass -p${pass} ssh ${user}@$sname chmod a+x /home/ethos/rigcheck_config.sh
    fi

    GreenEcho "Successfully copied to ${sname[$Index]}"

done