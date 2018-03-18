#!/bin/bash

###################################################################################
#
# The MIT License
#
# Copyright 2018 Sven Mielke <web@ddl.bz>.
#
# Repository: https://bitbucket.org/s3v3n/rigcheck.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# rigcheck_autoupdater.sh v.1.0.0 based on rigcheck.sh for ethOS 1.3.x by Sven Mielke
#
# Run as cronjob, every day at 0pm
#
# Set chmod
# chmod a+x /home/ethos/rigcheck_autoupdater.sh
#
# sudo crontab -e
# 0 0 * * * /home/ethos/rigcheck_autoupdater.sh
#
# Finished!
#
# Testing (try bash, calling sh make bash switch to posix mode and gives you some error)
# bash /home/ethos/rigcheck_autoupdater.sh
#
# Donation
# You can send donations to any of the following addresses:
# BTC:  1Py8NMWNmtuZ5avyHFS977wZWrUWBMrfZH
# ETH:  0x8e9e03f6895320081b15141f2dc5fabc40317e8c
# BCH:  19sp8nSeDWN4FGrKSoGKdbeSgijGW8NBh9
# BTCP: ﻿b1CCUUdgSXFkg2c65WZ855HmgS4jsC54VRg
#
# ENJOY!
###################################################################################


# If you wish that rigcheck can update itself, set autoUpdate to yes. Otherwise you get only a Telegram/Pushover notification about a new version.
autoUpdate="yes";
# END edit...


RedEcho(){ echo -e "$(tput setaf 1)$1$(tput sgr0)"; }
GreenEcho(){ echo -e "$(tput setaf 2)$1$(tput sgr0)"; }
YellowEcho(){ echo -e "$(tput setaf 3)$1$(tput sgr0)"; }

# Include user config file
. /home/ethos/rigcheck_config.sh

# Check if vars on rigcheck_config.sh was set
if [[ -z "${MIN_HASH}" && -z "${LOW_WATT}" && -z "${TOKEN}" && -z "${CHAT_ID}" ]]
then
    RedEcho "Please setup your vars in /home/ethos/rigcheck_config.sh!";
    exit 1
fi

# Get Hostname
RIGHOSTNAME="$(cat /etc/hostname)";
# Get worker name for Pushover service
worker="$(/opt/ethos/sbin/ethos-readconf worker)";



load () {
   result="$(curl -s https://api.bitbucket.org/2.0/repositories/s3v3n/rigcheck/commits | python -c 'import sys, json; print json.load(sys.stdin)["values"][0]["'${1}'"]')";
   echo ${result}
}

notify () {
  if [[ -z "${TOKEN}" && -z "${APP_TOKEN}" ]];
  then
    echo "No push notifications configured"
  fi

  if [ -n "${TOKEN}" ];
  then
    echo "Sending telegram...";
    #Telegram notification
    curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text="${1}" >> /dev/null
  fi

  if [ -n "${APP_TOKEN}" ];
  then
    echo "Sending pushover...";
    #Pushover notification
    curl -s --form-string "token=${APP_TOKEN}" \
            --form-string "user=${USER_KEY}" \
            --form-string "message=${1}" \
            https://api.pushover.net/1/messages.json >> /dev/null
  fi
}

# Get hash from LAST commit
hash="$(load hash)";
lastCommit="$(load date)";
modificationDate="$(date --date=$(stat -c%y rigcheck.sh | cut -c1-10) +"%s")";
lastUpdate="$(date --date=$lastCommit +%s)";

echo "Checking for new commit...";
sleep 0.3


if [ "${modificationDate}" \< "${lastUpdate}" ];
then

    GreenEcho "A new version of rigcheck for Rig ${worker} (${RIGHOSTNAME}) is available!. Download: https://bitbucket.org/s3v3n/rigcheck";

    if [ "${autoUpdate}" = "yes" ];
    then

        # Backup old one
        cp /home/ethos/rigcheck.sh /home/ethos/rigcheck__backup__.sh

        # Download new version
        wget -N -q https://bitbucket.org/s3v3n/rigcheck/raw/${hash}/rigcheck.sh -O /home/ethos/rigcheck.sh

        # Set chmod to new file
        chmod a+x /home/ethos/rigcheck.sh

        sleep 0.3

        GreenEcho "A new version of rigcheck was successfully installed, enjoy!";

        notify "Autoupdater Status: A new version of rigcheck was successfully installed on Rig ${worker} (${RIGHOSTNAME}), enjoy! More: https://bitbucket.org/s3v3n/rigcheck";
    else
        notify "Autoupdater Status: A new version of rigcheck for Rig ${worker} (${RIGHOSTNAME}) is available! Download: https://bitbucket.org/s3v3n/rigcheck";
    fi

else
    GreenEcho "rigcheck seems to be up to date.";

    notify "Autoupdater Status: rigcheck seems to be up to date. More: https://bitbucket.org/s3v3n/rigcheck"
fi
