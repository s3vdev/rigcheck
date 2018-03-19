#!/bin/bash

##
# Sven Mielke (march 2018) http://bitbucket.org/s3v3n/rigcheck
#
# Select your file, that you would like to transfer to all your mining rigs.
#
# Install "sshpass" - https://gist.github.com/arunoda/7790979
# @mac OS X: brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
# @Linux: apt-get update && apt-get install install sshpass
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

##
# Ask for file to copy
echo "Please enter the file that you would like to transfer to your ethOS rigs e.g. rigcheck.sh, followed by [ENTER]:"
read file

for sname in "${ethoservers[@]}"
do

    ##
	# This one copies the file to your rigs
	sshpass -p ${pass} scp ./${file} ${user}@$sname:/home/ethos/

    ##
    # This one set chmod 755 to file on your rigs
	sshpass -p${pass} ssh ${user}@$sname chmod a+x /home/ethos/${file}

    GreenEcho "${file} successfully copied to ${sname[$Index]}"
done