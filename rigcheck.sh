#!/bin/bash

###################################################################################
#
# The MIT License
#
# Copyright 2018 Sven Mielke <web@ddl.bz>.
#
# Repository: https://bitbucket.org/s3v3n/rigcheck - v1.0.16.
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

##
# Get human uptime
human_uptime="$(/opt/ethos/bin/human_uptime)";

##
# Include user config file
. /home/ethos/rigcheck_config.sh

##
# Check if vars on rigcheck_config.sh was set
if [[ -z "${MIN_TOTAL_HASH}" && -z "${LOW_WATT}" ]]
then
    RedEcho "Please setup your vars in /home/ethos/rigcheck_config.sh!";
    exit 1
fi


##
# Using total seconds from uptime (Thanks to Martin Lukas)
upinseconds="$(cat /proc/uptime | cut -d"." -f1)";

##
# if we haven't had a minumum of 15 minutes (900 seconds) since system started, bail
if [ "${upinseconds}" -lt "900" ];
then
  RedEcho "[ WARNING ] System booted less then 15 minutes ago. (Uptime: ${human_uptime}), rigcheck bailing!";
  echo $(date "+%d.%m.%Y %T") "System booted less then 15 minutes ago. (Uptime: ${human_uptime}), rigcheck bailing!" >> /home/ethos/rigcheck.log
  exit 1
fi


load () {
   result="$(curl -s ${STATSPANEL}/?json=yes | python -c 'import sys, json; print json.load(sys.stdin)["rigs"]["'${RIGHOSTNAME}'"]["'${1}'"]')";
   echo ${result}
}


stats () {
   result="$(cat /var/run/ethos/stats.json | python -c 'import sys, json; print json.load(sys.stdin)["'${1}'"]')";
   echo ${result}
}



##
# Get worker name for Pushover service
worker="$(/opt/ethos/sbin/ethos-readconf worker)";



##
# Check bioses or powertune to get nvidia "Unable to determine.." error
nvidiaErrorCheck="$(/opt/ethos/sbin/ethos-readdata bios | xargs | tr -s ' ' | grep "Unable to determine the device handle")";

##
# Get current fan speeds
fanrpm_raw="$(/opt/ethos/sbin/ethos-readdata fanrpm | xargs | tr -s ' ')";

##
# Get current mining client,
miner="$(/opt/ethos/sbin/ethos-readconf miner)";

##
# Hardware error: graphics driver did not load
nomine="$(cat /var/run/ethos/nomine.file)";

##
# Get adl_errors
adl_error="$(cat /var/run/ethos/adl_error.file)";

##
# Get current total hashrate (as integer)
hashRate="$(tail -10 /var/run/ethos/miner_hashes.file | sort -V | tail -1 | tr ' ' '\n' | awk '{sum +=$1} END {print sum}')";

##
# Get all availible GPUs
gpus="$(cat /var/run/ethos/gpucount.file)";

##
# Get stats panel
STATSPANEL="$(cat /var/run/ethos/url.file)";

##
# Get Hostname
RIGHOSTNAME="$(cat /etc/hostname)";

##
# Get driver
driver="$(/opt/ethos/sbin/ethos-readconf driver)";

##
# Get defunct gpu crashed: reboot required
defunct="$(ps uax | grep ${miner} | grep defunct | grep -v grep | wc -l)";

##
# GPU clock problem: gpu clocks are too low
gpucrashed="$(cat /var/run/ethos/crashed_gpus.file | wc -w)";

##
# Count fans (6)
fanCount="$(/opt/ethos/sbin/ethos-readdata fanrpm | xargs | tr -s ' ' | wc -w)";

##
# Count active GPUs
gpuCount="$(cat /var/run/ethos/gpucount.file)";

##
# power cable problem
no_cables="$(cat /var/run/ethos/nvidia_error.file)";

##
# overheat: one or more gpus overheated
overheat="$(cat /var/run/ethos/overheat.file)";

##
# Miner Hashes
miner_hashes_raw="$(tail -10 /var/run/ethos/miner_hashes.file | sort -V | tail -1)";

##
# Check ethOS auto reboots
auto_reboots="$(/opt/ethos/sbin/ethos-readconf autoreboot)";

##
# Show GPU memory
gpu_mem="$(/opt/ethos/sbin/ethos-readdata mem | xargs | tr -s ' ')";

##
# Stratum status
stratum_check="$(/opt/ethos/sbin/ethos-readconf stratumenabled)";

##
# Miner version
miner_version="$(cat /var/run/ethos/miner.versions | grep ${miner} | cut -d" " -f2 | head -1)";

##
# Possible miner stall (look for status "possible miner stall" and restart rig)
miner_stall="$(cat /var/run/ethos/status.file | grep "possible miner stall: check miner log")";

##
# Rounding decimal hashrate values to INT (Thanks to Martin Lukas)
hashRateInt=${hashRate%.*};

##
# Add watts check (best way to detect crash for Nvidia cards) (Thanks to Min Min)
if [ "${driver}" = "nvidia" ]; then
    watts_raw="$(/opt/ethos/bin/stats | grep watts | cut -d' ' -f2- | sed -e 's/^[ \t]*//')";
fi

##
# Get miner runtime in seconds
MinerSeconds=$(stats "miner_secs");

##
# stats.josn ethOS ver. 1.3.x
StatsJson="/var/run/ethos/stats.json";


##
# Human miner runtime
MinerTime=$(printf '%dh:%dm:%ds' $(($MinerSeconds/3600)) $(($MinerSeconds%3600/60)) $(($MinerSeconds%60)))
#echo $MinerTime;

#stats "miner";
#exit 1

##
# Logfile
LogFile="/home/ethos/rigcheck.log";


##
# Check if minercounter have a value
if [[ ! -f /dev/shm/restartminercount ]]; then
	echo "0" > /dev/shm/restartminercount
fi

##
# Get restart miner counts
RestartMinerCount=$(cat /dev/shm/restartminercount)



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


### EXIT IF STATS.JSON IS MISSING
if [[ ! -f "$StatsJson" ]]; then
	echo "$(date "+%d.%m.%Y %T") EXIT: stats.json not available yet.(make sure ethosdistro is ver: 1.3.0+)" | tee -a "$LogFile"
	notify "Rig ${worker} (${RIGHOSTNAME})"$'\n\n'"Error: stats.json not available yet.(make sure ethOS is ver: 1.3.0+. Run sudo ethos-update in your terminal.";
	exit 1
fi

function RestartMiner() {

	##
	# COUNT RESTARTS IF MINNER IS RUNNING FOR LESS THEN 1H
	if [[ "${MinerSeconds}" -lt 3600 ]]; then
		let RestartMinerCount++
		echo "$RestartMinerCount" > /dev/shm/restartminercount
	else
		echo "0" > /dev/shm/restartminercount
	fi

	##
	# REBOOT ON TO MANY MINERRESTART'S
	if [[ "${RestartMinerCount}" -ge "${RebootMaxRestarts}" ]]; then
		echo "$(date "+%d.%m.%Y %T") REBOOT: To many miner restarts within 1h. [Miner was running for: $MinerTime]" | tee -a "$LogFile"
		notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during to many miner restarts within 1h. [Miner was running for: $MinerTime]";
		rm "$StatsJson" -f
		sudo reboot
		exit
	fi

	rm "$StatsJson" -f
	sudo /opt/ethos/bin/minestop
	exit
}



function Json2Array() {
	Index=0
	x=' ' read -r -a Values <<< "`stats "${1}"`"
	if [[ $Values != "null" ]]; then
		for Value in "${Values[@]}"
		do
			eval "$1[$Index]"="$Value"
		    let Index++
		done
	fi
}


##
# SKIP CHECKS IF MINER IS RUNNING LESS THEN 5 MINUTES
if [[ "${MinerSeconds}" -gt 300 ]]; then

    Json2Array miner_hashes
    Json2Array watts
    Json2Array core
    Json2Array mem
    Json2Array fanrpm

    Index=0

    for Value in "${miner_hashes[@]}"
    do
        if [[ "${miner_hashes[$Index]/.*}" -lt $MIN_HASHRATE_GPU ]]; then
            RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - RESTART: GPU[$Index] HASH:${miner_hashes[$Index]} CORE:${core[$Index]} MEM:${mem[$Index]} FANRPM:${fanrpm[$Index]}. [Miner was running for: $MinerTime]" | tee -a "$LogFile"
            notify "Rig ${worker} (${RIGHOSTNAME})"$'\n\n'"RESTART [hash < min_hashrate_gpu]"$'\n'"GPU[$Index]"$'\n'"HASH:${miner_hashes[$Index]}"$'\n'"CORE:${core[$Index]}"$'\n'"MEM:${mem[$Index]}"$'\n'"FANRPM:${fanrpm[$Index]}."$'\n'"[Miner was running for: $MinerTime]"
            RestartMiner
        elif [[ "${driver}" = "nvidia" && "${watts[$Index]/.*}" -lt $LOW_WATT ]]; then
            RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - RESTART: GPU[$Index] WATTS:${watts[$Index]}.[Miner was running for: $MinerTime]" | tee -a "$LogFile"
            notify "Rig ${worker} (${RIGHOSTNAME})"$'\n\n'"RESTART [watts < low_watt]"$'\n'"GPU[$Index]"$'\n'"WATTS:${watts[$Index]}"$'\n'"CORE:${core[$Index]}"$'\n'"MEM:${mem[$Index]}"$'\n'"FANRPM:${fanrpm[$Index]}."$'\n'"[Miner was running for: $MinerTime]"
            RestartMiner
        else
            GreenEcho "STATUS OK: GPU[$Index] HASH:${miner_hashes[$Index]} WATTS:${watts[$Index]} CORE:${core[$Index]} MEM:${mem[$Index]} FANRPM:${fanrpm[$Index]}"
            sleep 0.3
        fi
        let Index++
    done

else
	echo "EXIT: Miner running for less then 5 minutes.[Miner running for: $MinerTime]"
	exit
fi



if [ "${defunct}" -gt "0" ];
then
    RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - GPU CLOCK PROBLEM: GPU clock problem: gpu clocks are too low - TRYING TO REBOOT THE RIG!" | tee -a "$LogFile"
    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during GPU clock problem: GPU HASH:${hashRate}. [Miner was running for: $MinerTime]"
    RestartMiner
else
    GreenEcho "STATUS OK: NO GPU CLOCK PROBLEM DETECTED";
fi



if [ "${gpucrashed}" -gt "0" ];
then
    RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - GPU CRASHED: Rebooting during GPU clock problem: gpu clocks are too low. [Miner was running for: $MinerTime]" | tee -a "$LogFile"
    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during GPU clock problem: gpu clocks are too low. [Miner was running for: $MinerTime]"
    RestartMiner
    exit 1
else
    GreenEcho "STATUS OK: NO GPU CRASH DETECTED";
fi


sleep 0.3


# Check for GPU error (NVIDIA)
if [ "${driver}" = "nvidia" ];
then

    if [ -n "${nvidiaErrorCheck}" ];
        then
            RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - GPU LOST: Rebooting during GPU ERROR. Error was: GPU LOST. [Miner was running for: $MinerTime]" | tee -a "$LogFile"
            notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during GPU ERROR. Error was: GPU LOST. [Miner was running for: $MinerTime]"
            RestartMiner
            exit 1
        else
            GreenEcho "STATUS OK: NO GPU LOST DETECTED";
    fi
fi


sleep 0.3


# Restart Rig if fanrpm empty/error (3 - 4)
if [ "${fanCount}" -lt "${gpuCount}" ];
then
    RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - FAN ERROR: Rebooting during FAN ERROR. Fan RPM was: ${fanrpm_raw}. [Miner was running for: $MinerTime]" | tee -a "$LogFile"
    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during FAN ERROR. Fan RPM was: ${fanrpm_raw}. [Miner was running for: $MinerTime]"
    RestartMiner
    exit 1
else
    GreenEcho "STATUS OK: FAN RPM SEEMS TO BE OK";
fi


sleep 0.3


if [ -n "${no_cables}" ];
then
    RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - POWER CABLE PROBLEM: PCI-E power cables not seated properly! [Miner was running for: $MinerTime]" | tee -a "$LogFile"
    notify "Rig ${worker} (${RIGHOSTNAME}) Power cable problem: PCI-E power cables not seated properly. [Miner was running for: $MinerTime]"
    #RestartMiner
    #exit 1
else
    GreenEcho "STATUS OK: POWER CABLE SEEMS TO BE OKAY AND WORKING";
fi


sleep 0.3


if [ -n "${adl_error}" ];
then
    RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - HARDWARE ERROR: Possible gpu/riser/power failure! [Miner was running for: $MinerTime]" | tee -a "$LogFile"
    notify "Rig ${worker} (${RIGHOSTNAME}) Hardware error: possible gpu/riser/power failure. [Miner was running for: $MinerTime]"
    RestartMiner
    exit 1
else
    GreenEcho "STATUS OK: NO HARDWARE ERROR DETECTED";
fi


sleep 0.3


if [ -n "${overheat}" ];
then
    RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - OVERHEAT: One or more GPUS overheated! [Miner was running for: $MinerTime]" | tee -a "$LogFile"
    notify "Rig ${worker} (${RIGHOSTNAME}) Overheat: one or more gpus overheated"
    RestartMiner
    exit 1
else
    GreenEcho "STATUS OK: NO GPUS OVERHEATED";
fi


sleep 0.3


# Restart miner if hashrate less than MIN_TOTAL_HASH or 0
if [[ "${hashRateInt}" = "0" || "${hashRateInt}" -lt "${MIN_TOTAL_HASH}" ]];
then
    RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - TOTAL HASHARTE MISSMATCH: Total hashrate was: ${hashRate} hash (hashes per GPU: ${miner_hashes_raw}). Your MIN_HASH is ${MIN_TOTAL_HASH}. [Miner was running for: $MinerTime]";
    notify "Miner (${miner}) on Rig ${worker} (${RIGHOSTNAME}) has restarted during total hashrate. Total hashrate was: ${hashRate} hash (hashes per GPU: ${miner_hashes_raw}). Your MIN_HASH is ${MIN_TOTAL_HASH}. [Miner was running for: $MinerTime]" | tee -a "$LogFile"

    RestartMiner
    exit 1
else
    GreenEcho "STATUS OK: TOTAL HASHRATE SEEMS TO BE OK. ${hashRate} (INT ${hashRateInt}) hash";
fi


sleep 0.3


#IFS=' ' read -r -a watts <<< "$watts_raw"
#for watt in "${watts[@]}"; do
#    if ((watt < $LOW_WATT)); then
#        RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - GPU CARD WATTAGE TOO LOW. ACTUAL: ${watt} MINIMUM: ${LOW_WATT}" | tee -a "$LogFile"
#        notify "$(date "+%d.%m.%Y %T") - Miner (${miner}) on Rig ${worker} (${RIGHOSTNAME}) has restarted during GPU wattage too low. Actual wattage: ${watt}. Minimum wattage: ${LOW_WATT}. [Miner was running for: $MinerTime]"
#        RestartMiner
#        exit 1
#    else
#        GreenEcho "STATUS OK: GPU WATTAGE SEEMS TO BE OK";
#    fi
#done


sleep 0.3


if [ -n "${miner_stall}" ];
then
    RedEcho "STATUS FAIL: $(date "+%d.%m.%Y %T") - MINER STALL: Rebooting during MINER STALL. Miner has been working for a while, but hash is zero. [Miner was running for: $MinerTime]" | tee -a "$LogFile"
    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during MINER STALL. Miner has been working for a while, but hash is zero. [Miner was running for: $MinerTime]"
    RestartMiner
    exit 1
else
    GreenEcho "STATUS OK: NO POSSIBLE MINER STALL DETECTED";
fi


sleep 0.3

#### PASS TESTINGS ####

### SOME TESTS ###
echo ""
GreenEcho "##### VISUAL CONTROL #####";
echo "STRATUM: ${stratum_check}";
echo "MINER: ${miner} ${miner_version}";
echo " running for ${MinerTime}";
echo "TOTAL HASH: ${hashRate} hash";
echo "YOUR MIN HASH: ${MIN_TOTAL_HASH} hash";
echo "GPUs: ${gpus}";
echo "DRIVER: ${driver}";
#echo "HASHES PER GPU: ${miner_hashes_raw}";
#echo "MEM PER GPU: ${gpu_mem}";

# Check if we're on nvidia rigs so we can grep watts of GPUs
if [ "${driver}" = "nvidia" ];
then
    echo "WATTS: ${watts_raw}";
else
    echo "WATTS: (NOT AVAILABLE ON AMD GPUS)"
fi

#echo "FAN RPM: ${fanrpm_raw}";
#echo "UPTIME: ${human_uptime}";
#echo "AUTO REBOOTS ${auto_reboots}";
echo "REBOOT ON TO MANY MINER RESTARTS: ${RestartMinerCount}/${RebootMaxRestarts}"
GreenEcho "##### VISUAL CONTROL END #####";

echo ""
GreenEcho "Rig ${worker} seems to work properly since ${human_uptime}."
echo ""
