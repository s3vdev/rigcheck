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
# Donation
# You can send donations to any of the following addresses:
# BTC:  1Py8NMWNmtuZ5avyHFS977wZWrUWBMrfZH
# ETH:  0x8e9e03f6895320081b15141f2dc5fabc40317e8c
# BCH:  19sp8nSeDWN4FGrKSoGKdbeSgijGW8NBh9
# BTCP: ﻿b1CCUUdgSXFkg2c65WZ855HmgS4jsC54VRg
#
# Testing (try bash, calling sh make bash switch to posix mode and gives you some error)
# bash /home/ethos/rigcheck_autoupdater.sh
#
# ENJOY!
###################################################################################


### BEGINN EDIT ###

# If you wish that rigcheck can update itself, set autoUpdate to yes
autoUpdate="yes";

### END EDIT ###



## Auto update testing
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)" # No Color
# Include user config file
. /home/ethos/rigcheck_config.sh
# Get Hostname
RIGHOSTNAME="$(cat /etc/hostname)";
# Get worker name for Pushover service
worker="$(/opt/ethos/sbin/ethos-readconf worker)";
# Get version from bitbucket
versionsCheck="$(curl -s https://bitbucket.org/s3v3n/rigcheck/raw/3b9ad8bb4b0ce2212bfc4a1f728c25772cdb466d/version)";


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



echo "Checking...";
if [ "${versionsCheck}" \> "${currentVersion}" ];
then
    echo "${GREEN}A new version of rigcheck (current: ${currentVersion} new: ${versionsCheck}) for Rig ${worker} (${RIGHOSTNAME}) is available!${NC}. Download: https://bitbucket.org/s3v3n/rigcheck"

    if [ "${autoUpdate}" = "yes" ];
    then

        wget -N -q https://bitbucket.org/s3v3n/rigcheck/raw/3b9ad8bb4b0ce2212bfc4a1f728c25772cdb466d/rigcheck.sh -O /home/ethos/rigcheck.sh
        chmod a+x /home/ethos/rigcheck.sh

        sleep 0.3

        # Set NEW version to this script
        newVersion=${versionsCheck};

        str="currentVersion=${currentVersion}";
        find="${currentVersion}";
        replace="${versionsCheck}";
        result="${str//$find/$replace}";


        notify "A new version of rigcheck (${versionsCheck}) was successfully installed on Rig ${worker} (${RIGHOSTNAME}), enjoy!"

    else
        notify "A new version of rigcheck (current: ${currentVersion} new: ${versionsCheck}) for Rig ${worker} (${RIGHOSTNAME}) is available! Download: https://bitbucket.org/s3v3n/rigcheck"
    fi

else
    echo "${versionsCheck} seems to be up to date."
fi
