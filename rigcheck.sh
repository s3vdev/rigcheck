#!/bin/bash

###################################################################################
#
# The MIT License
#
# Copyright 2018 Sven Mielke <web@ddl.bz>.
#
# Repository: https://bitbucket.org/s3v3n/rigcheck - v1.0.15.
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
# rigcheck based on ethOS 1.3.x
#
# Run as cronjob, for example every 5 minutes
#
# Set chmod
# chmod a+x /home/ethos/rigcheck.sh
#
# sudo crontab -e
# */5 * * * * /home/ethos/rigcheck.sh
#
# Edit your vars in rigcheck.config
#
# Finished!
#
# Testing (try bash, calling sh make bash switch to posix mode and gives you some error)
# bash /home/ethos/rigcheck.sh
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

# Get worker name for Pushover service
worker="$(/opt/ethos/sbin/ethos-readconf worker)";
# Get human uptime
human_uptime="$(/opt/ethos/bin/human_uptime)";
# Check bioses or powertune to get nvidia "Unable to determine.." error
nvidiaErrorCheck="$(/opt/ethos/sbin/ethos-readdata bios | xargs | tr -s ' ' | grep "Unable to determine the device handle")";
# Get current fan speeds
fanrpm="$(/opt/ethos/sbin/ethos-readdata fanrpm | xargs | tr -s ' ')";
# Get current mining client,
miner="$(/opt/ethos/sbin/ethos-readconf miner)";
# Hardware error: graphics driver did not load
nomine="$(cat /var/run/ethos/nomine.file)";
adl_error="$(cat /var/run/ethos/adl_error.file)";
# Get current total hashrate (as integer)
hashRate="$(tail -10 /var/run/ethos/miner_hashes.file | sort -V | tail -1 | tr ' ' '\n' | awk '{sum +=$1} END {print sum}')";
# Get all availible GPUs
gpus="$(cat /var/run/ethos/gpucount.file)";
# Get stats panel
STATSPANEL="$(cat /var/run/ethos/url.file)";
# Get Hostname
RIGHOSTNAME="$(cat /etc/hostname)";
# Get driver
driver="$(/opt/ethos/sbin/ethos-readconf driver)";
# Get defunct gpu crashed: reboot required
defunct="$(ps uax | grep ${miner} | grep defunct | grep -v grep | wc -l)";
# GPU clock problem: gpu clocks are too low
gpucrashed="$(cat /var/run/ethos/crashed_gpus.file | wc -w)";
# Count fans (6)
fanCount="$(/opt/ethos/sbin/ethos-readdata fanrpm | xargs | tr -s ' ' | wc -w)";
# Count active GPUs
gpuCount="$(cat /var/run/ethos/gpucount.file)";
# power cable problem
no_cables="$(cat /var/run/ethos/nvidia_error.file)";
# overheat: one or more gpus overheated
overheat="$(cat /var/run/ethos/overheat.file)";
# Miner Hashes
miner_hashes="$(tail -10 /var/run/ethos/miner_hashes.file | sort -V | tail -1)";
# Check ethOS auto reboots
auto_reboots="$(/opt/ethos/sbin/ethos-readconf autoreboot)";
# Show GPU memory
gpu_mem="$(/opt/ethos/sbin/ethos-readdata mem | xargs | tr -s ' ')";
# Stratum status
stratum_check="$(/opt/ethos/sbin/ethos-readconf stratumenabled)";
# Miner version
miner_version="$(cat /var/run/ethos/miner.versions | grep ${miner} | cut -d" " -f2 | head -1)";
# Possible miner stall (look for status "possible miner stall" and restart rig)
miner_stall="$(cat /var/run/ethos/status.file | grep "possible miner stall: check miner log")";
# Rounding decimal hashrate values to INT (Thanks to Martin Lukas)
hashRateInt=${hashRate%.*}
# Using total seconds from uptime (Thanks to Martin Lukas)
upinseconds="$(cat /proc/uptime | cut -d"." -f1)";
# Add watts check (best way to detect crash for Nvidia cards) (Thanks to Min Min)
watts_raw="$(/opt/ethos/bin/stats | grep watts | cut -d' ' -f2- | sed -e 's/^[ \t]*//')";


# if we haven't had a minumum of 15 minutes (900 seconds) since system started, bail
if [ "${upinseconds}" -lt "900" ];
then
  RedEcho "[ WARNING ] Not enough time (15 minutes) since reboot (Uptime: ${human_uptime}), rigcheck bailing!";
  echo `date +%d.%m.%Y_%H:%M:%S`  "Not enough time since reboot (Uptime: ${human_uptime}), rigcheck bailing!" >> /home/ethos/rigcheck.log
  exit 1
fi


load () {
   result="$(curl -s ${STATSPANEL}/?json=yes | python -c 'import sys, json; print json.load(sys.stdin)["rigs"]["'${RIGHOSTNAME}'"]["'${1}'"]')";
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



if [ "${defunct}" -gt "0" ];
then
    RedEcho "[ FAIL ] GPU clock problem: gpu clocks are too low - TRYING TO REBOOT THE RIG!";

    # Write  reboots to logfile
    echo $(date "+%d.%m.%Y %T") "Rig has rebooted during GPU clock problem: gpu clocks are too low. Hashrate was: ${hashRate} MH/s. Total uptime was: ${human_uptime}" >> /home/ethos/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during GPU clock problem: gpu clocks are too low. Hashrate was: ${hashRate} MH/s.  Total uptime was: ${human_uptime}"

    sudo /opt/ethos/bin/r # <= ethOS command to reboot
    exit 1

else
    GreenEcho "[ OK ] NO GPU CLOCK PROBLEM DETECTED";
fi

sleep 0.3

if [ "${gpucrashed}" -gt "0" ];
then
    RedEcho "[ FAIL ] GPU CRASHED - TRYING TO REBOOT THE RIG!";

    # Write  reboots to logfile
    echo $(date "+%d.%m.%Y %T") "Rig has rebooted during GPU CRASHED. Hashrate was: ${hashRate} MH/s. Total uptime was: ${human_uptime}" >> /home/ethos/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during GPU clock problem: gpu clocks are too low. Hashrate was: ${hashRate} MH/s.  Total uptime was: ${human_uptime}"

    sudo /opt/ethos/bin/r # <= ethOS command to reboot
    exit 1

else
    GreenEcho "[ OK ] NO GPU CRASH DETECTED";
fi

sleep 0.3

# Check for GPU error (NVIDIA)
if [ "${driver}" = "nvidia" ];
then

    if [ -n "${nvidiaErrorCheck}" ];
        then
            RedEcho "[ FAIL ] GPU LOST - TRYING TO REBOOT THE RIG!";

            # Write  reboots to logfile
            echo $(date "+%d.%m.%Y %T") "Rig has rebooted during GPU ERROR. Error was: GPU LOST. Total uptime was: ${human_uptime}" >> /home/ethos/rigcheck.log

            notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during GPU ERROR. Error was: GPU LOST. Total uptime was: ${human_uptime}"

            sudo /opt/ethos/bin/r # <= ethOS command to reboot
            exit 1

        else
            GreenEcho "[ OK ] NO GPU LOST DETECTED";
    fi
fi

sleep 0.3

# Restart Rig if fanrpm empty/error (3 - 4)
if [ "${fanCount}" -lt "${gpuCount}" ];
then
    RedEcho "[ FAIL ] FAN ERROR - TRYING TO REBOOT THE RIG!";

    # Write  reboots to logfile
    echo $(date "+%d.%m.%Y %T") "Rig has rebooted during FAN ERROR. Fan RPM was: ${fanrpm}. Total uptime was: ${human_uptime}" >> /home/ethos/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during FAN ERROR. Fan RPM was: ${fanrpm}. Total uptime was: ${human_uptime}"

    sudo /opt/ethos/bin/r # <= ethOS command to reboot
    exit 1

else
    GreenEcho "[ OK ] FAN RPM SEEMS TO BE OK";
fi

sleep 0.3

if [ -n "${no_cables}" ];
then
    RedEcho "[ FAIL ] Power cable problem: PCI-E power cables not seated properly!";

    # Write  reboots to logfile
    echo $(date "+%d.%m.%Y %T") "Power cable problem: PCI-E power cables not seated properly" >> /home/ethos/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) Power cable problem: PCI-E power cables not seated properly"

    #sudo /opt/ethos/bin/r # <= ethOS command to reboot
    #exit 1

else
    GreenEcho "[ OK ] POWER CABLE SEEMS TO BE OKAY AND WORKING";
fi

sleep 0.3

if [ -n "${adl_error}" ];
then
    RedEcho "[ FAIL ] Hardware error: possible gpu/riser/power failure!";

    # Write  reboots to logfile
    echo $(date "+%d.%m.%Y %T") "Hardware error: possible gpu/riser/power failure" >> /home/ethos/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) Hardware error: possible gpu/riser/power failure."

    sudo /opt/ethos/bin/r # <= ethOS command to reboot
    exit 1

else
    GreenEcho "[ OK ] NO HARDWARE ERROR DETECTED";
fi

sleep 0.3

if [ -n "${overheat}" ];
then
    RedEcho "[ FAIL ] Overheat: one or more gpus overheated!";

    # Write  reboots to logfile
    echo $(date "+%d.%m.%Y %T") "Overheat: one or more gpus overheated" >> /home/ethos/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) Overheat: one or more gpus overheated"

    #sudo /opt/ethos/bin/r # <= ethOS command to reboot
    #exit 1

else
    GreenEcho "[ OK ] ";
fi

sleep 0.3

# Restart miner if hashrate less than MIN_HASH or 0
if [[ "${hashRateInt}" = "0"  || "${hashRateInt}" -lt "${MIN_HASH}" ]];
then
    RedEcho "[ FAIL ] HASHARTE MISSMATCH - TRYING TO RESTART MINER!";

    # Write  reboots to logfile
    echo $(date "+%d.%m.%Y %T") "Miner (${miner}) has restarted during hashrate missmatch. Total hashrate was: ${hashRate} hash (hashes per GPU: ${miner_hashes}). Your MIN_HASH is ${MIN_HASH}. Total uptime was: ${human_uptime}" >> /home/ethos/rigcheck.log

    notify "Miner (${miner}) on Rig ${worker} (${RIGHOSTNAME}) has restarted during missmatch. Total hashrate was: ${hashRate} hash (hashes per GPU: ${miner_hashes}). Your MIN_HASH is ${MIN_HASH}. Total uptime was: ${human_uptime}"

    /opt/ethos/bin/minestop

    #sudo /opt/ethos/bin/r # <= ethOS command to reboot
    #exit 1

else
    GreenEcho "[ OK ] HASHRATE SEEMS TO BE OK. ${hashRate} (INT ${hashRateInt}) hash";
fi

sleep 0.3

if [ -n "${miner_stall}" ];
then
    RedEcho "[ FAIL ] Miner stall: possible miner stall: check miner log!";

    # Write  reboots to logfile
    echo $(date "+%d.%m.%Y %T") "Miner stall: possible miner stall: check miner log" >> /home/ethos/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during MINER STALL. Miner has been working for a while, but hash is zero. Total uptime was: ${human_uptime}"

    sudo /opt/ethos/bin/r # <= ethOS command to reboot
    exit 1

else
    GreenEcho "[ OK ] NO POSSIBLE MINER STALL DETECTED";
fi

sleep 0.3

IFS=' ' read -r -a watts <<< "$watts_raw"
for watt in "${watts[@]}"; do
    if ((watt < $LOW_WATT)); then

        RedEcho "[ FAIL ] GPU CARD WATTAGE TOO LOW. ACTUAL: ${watt} MINIMUM: ${LOW_WATT}";

        # Write  reboots to logfile
        echo $(date "+%d.%m.%Y %T") "Miner (${miner}) has restarted because GPU wattage too low. Actual wattage: ${watt}. Minimum wattage: ${LOW_WATT}. Total uptime was: ${human_uptime}" >> /home/ethos/rigcheck.log

        notify "Miner (${miner}) on Rig ${worker} (${RIGHOSTNAME}) has restarted during GPU wattage too low. Actual wattage: ${watt}. Minimum wattage: ${LOW_WATT}. Total uptime was: ${human_uptime}"

        sudo /opt/ethos/bin/r # <= ethOS command to reboot
        exit 1

    else
        GreenEcho "[ OK ] GPU WATTAGE SEEMS TO BE OK";
    fi
done

sleep 0.3

#### PASS TESTINGS ####

### SOME TESTS ###
echo ""
GreenEcho "##### VISUAL CONTROL #####";
echo "STRATUM: ${stratum_check}";
echo "MINER: ${miner} ${miner_version}";
echo "TOTAL HASH: ${hashRate} hash";
echo "YOUR MIN HASH: ${MIN_HASH} hash";
echo "GPUs: ${gpus}";
echo "DRIVER: ${driver}";
echo "HASHES PER GPU: ${miner_hashes}";
echo "MEM PER GPU: ${gpu_mem}";
echo "WATTS: ${watts_raw}";
echo "FAN RPM: ${fanrpm}";
echo "UPTIME: ${human_uptime}";
echo "AUTO REBOOTS ${auto_reboots}";
GreenEcho "##### VISUAL CONTROL END #####";

echo ""
echo "Rig ${worker} seems to work properly since ${human_uptime}."
echo ""
