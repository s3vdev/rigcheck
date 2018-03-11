#!/bin/bash

###################################################################################
#
# rigcheck v.1.0.12 (March 2018) based on ethOS 1.3.x by Sven Mielke
# https://bitbucket.org/s3v3n/rigcheck-for-ethos-1.3.x/
#
# Run as cronjob every 5 min.
#
# Set chmod
# chmod a+x /home/ethos/rigcheck.sh
#
# sudo crontab -e
# */5 * * * * /home/ethos/rigcheck.sh
#
#
# Finished!
#
# Telegram Notification (optional):
# Get status messages directly from your mining rigs if some errors occurred.
#
# 1. Open your Telegram App
# 2. GLOBAL SEARCH -> BotFather
# 3. Create a new bot by typing/clicking /newbot
# 4. Choose a user-friendly name for your bot, for example: awesomebot
# 5. Choose a unique username for your bot (must end with 'bot' )
# 6. copy your <TOKEN> e.g. 4334584910:AAEPmjlh84N62Lv3jGWEgOftlxxAfMhB1gs
# 7. Start a conversation with your bot: GLOBAL SEARCH -> MY_BOT_NAME -> START
# 8. To get the chat ID, open the following URL in your web-browser:
#    https://api.telegram.org/bot<TOKEN>/getUpdates
# 9. copy your chat id in var CHAT_ID and your token to TOKEN below
#
#
# Pushover.net Notification (optional):
# register your free account and get all status message to your Phone/Tablet.
#
# Donation
# BTC: 1Py8NMWNmtuZ5avyHFS977wZWrUWBMrfZH
# ETH: 0x8e9e03f6895320081b15141f2dc5fabc40317e8c
# BCH: 19sp8nSeDWN4FGrKSoGKdbeSgijGW8NBh9
#
# ENJOY!
###################################################################################


### BEGINN EDIT ###

# If your hashrate is less than :min_hash, your miner will restart automatically
MIN_HASH="";

# Telegram Gateway Service
TOKEN="";
CHAT_ID="";

# Pushover.net Gateway Service
APP_TOKEN="";
USER_KEY="";

### END EDIT ###




# Coloring for consolen output...
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
NC="$(tput sgr0)" # No Color
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
#read -d. hashRate_int <<< "$(tail -10 /var/run/ethos/miner_hashes.file | sort -V | tail -1 | tr ' ' '\n' | awk '{sum +=$1} END {print sum}')";
hashRate="$(tail -10 /var/run/ethos/miner_hashes.file | sort -V | tail -1 | tr ' ' '\n' | awk '{sum +=$1} END {print sum}')";
# Get all availible GPUs
gpus="$(cat /var/run/ethos/gpucount.file)";
# Get stats panel
STATSPANEL="$(cat /var/run/ethos/url.file)";
#Get Hostname
RIGHOSTNAME="$(cat /etc/hostname)";

# uptime in seconds
#read -d. uptime < /proc/uptime


## NEW jan. 2018
driver="$(/opt/ethos/sbin/ethos-readconf driver)";
# gpu crashed: reboot required
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


## NEW feb. 2018
# uptime in seconds
uptime="$(cat /proc/uptime)";
uptime=${uptime%%.*}

seconds=$(( uptime%60 ));
minutes=$(( uptime/60%60 ));
hours=$(( uptime/60/60%24 ));
days=$(( uptime/60/60/24 ));
#echo "$days days, $hours hours, $minutes minutes, $seconds seconds"


## NEW march 2018
# Possible miner stall (look for status "possible miner stall" and restart rig)
miner_stall="$(cat /var/run/ethos/status.file | grep "possible miner stall: check miner log")";



## begin...
# if we haven't had a minumum of 15 minutes since system started, bail
if [ "${minutes}" -lt "15" ];
then
  echo `date +%d.%m.%Y_%H:%M:%S`  "Not enough time since reboot (Uptime: ${human_uptime}), rigcheck bailing." >> /var/log/rigcheck.log
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
    curl -s -X POST https://api.telegram.org/bot${TOKEN}/sendMessage -d chat_id=${CHAT_ID} -d text="${1}"
  fi

  if [ -n "${APP_TOKEN}" ];
  then
    echo "Sending pushover...";
    #Pushover notification
    curl -s --form-string "token=${APP_TOKEN}" \
            --form-string "user=${USER_KEY}" \
            --form-string "message=${1}" \
            https://api.pushover.net/1/messages.json
  fi
}

if [ "${defunct}" -gt "0" ];
then
    echo "${RED}[ FAIL ]${NC} GPU clock problem: gpu clocks are too low - TRYING TO REBOOT THE RIG";

    # Write  reboots to logfile
    echo `date +%d.%m.%Y_%H:%M:%S`  "Rig has rebooted during GPU clock problem: gpu clocks are too low. Hashrate was: ${hashRate} MH/s. Total uptime was: ${human_uptime}" >> /var/log/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during GPU clock problem: gpu clocks are too low. Hashrate was: ${hashRate} MH/s.  Total uptime was: ${human_uptime}"

    /opt/ethos/bin/r # <= ethOS command to reboot

else
    echo "${GREEN}[ OK ]${NC} NO GPU CLOCK PROBLEM DETECTED"
fi

sleep 0.3

if [ "${gpucrashed}" -gt "0" ];
then
    echo "${RED}[ FAIL ]${NC} GPU CRASHED - TRYING TO REBOOT THE RIG";

    # Write  reboots to logfile
    echo `date +%d.%m.%Y_%H:%M:%S`  "Rig has rebooted during GPU CRASHED. Hashrate was: ${hashRate} MH/s. Total uptime was: ${human_uptime}" >> /var/log/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during GPU clock problem: gpu clocks are too low. Hashrate was: ${hashRate} MH/s.  Total uptime was: ${human_uptime}"

    /opt/ethos/bin/r # <= ethOS command to reboot

else
    echo "${GREEN}[ OK ]${NC} NO GPU CRASH DETECTED"
fi

sleep 0.3

# Check for GPU error (NVIDIA)
if [ "${driver}" = "nvidia" ];
then

    if [ -n "${nvidiaErrorCheck}" ];
        then
            echo "${RED}[ FAIL ]${NC} GPU LOST - TRYING TO REBOOT THE RIG";

            # Write  reboots to logfile
            echo `date +%d.%m.%Y_%H:%M:%S` "Rig has rebooted during GPU ERROR. Error was: GPU LOST. Total uptime was: ${human_uptime}" >> /var/log/rigcheck.log

            notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during GPU ERROR. Error was: GPU LOST. Total uptime was: ${human_uptime}"

            /opt/ethos/bin/r # <= ethOS command to reboot

        else
            echo "${GREEN}[ OK ]${NC} NO GPU LOST DETECTED"
    fi
fi

sleep 0.3

# Restart Rig if fanrpm empty/error (3 - 4)
if [ "${fanCount}" -lt "${gpuCount}" ];
then
    echo "${RED}[ FAIL ]${NC} FAN ERROR - TRYING TO REBOOT THE RIG";

    # Write  reboots to logfile
    echo `date +%d.%m.%Y_%H:%M:%S` "Rig has rebooted during FAN ERROR. Fan RPM was: ${fanrpm}. Total uptime was: ${human_uptime}" >> /var/log/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during FAN ERROR. Fan RPM was: ${fanrpm}. Total uptime was: ${human_uptime}"

    /opt/ethos/bin/r # <= ethOS command to reboot

else
    echo "${GREEN}[ OK ]${NC} FAN RPM SEEMS TO BE OK"
fi

sleep 0.3

if [ -n "${no_cables}" ];
then
    echo "${RED}[ FAIL ]${NC} Power cable problem: PCI-E power cables not seated properly";

    # Write  reboots to logfile
    echo `date +%d.%m.%Y_%H:%M:%S`  "Power cable problem: PCI-E power cables not seated properly" >> /var/log/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) Power cable problem: PCI-E power cables not seated properly"

    #/opt/ethos/bin/r # <= ethOS command to reboot

else
    echo "${GREEN}[ OK ]${NC} POWER CABLE SEEMS TO BE OKAY AND WORKING"
fi

sleep 0.3

if [ -n "${adl_error}" ];
then
    echo "${RED}[ FAIL ]${NC} Hardware error: possible gpu/riser/power failure";

    # Write  reboots to logfile
    echo `date +%d.%m.%Y_%H:%M:%S`  "Hardware error: possible gpu/riser/power failure" >> /var/log/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) Hardware error: possible gpu/riser/power failure."

    /opt/ethos/bin/r # <= ethOS command to reboot

else
    echo "${GREEN}[ OK ]${NC} NO HARDWARE ERROR DETECTED"
fi

sleep 0.3

if [ -n "${overheat}" ];
then
    echo "${RED}[ FAIL ]${NC} Overheat: one or more gpus overheated";

    # Write  reboots to logfile
    echo `date +%d.%m.%Y_%H:%M:%S`  "Overheat: one or more gpus overheated" >> /var/log/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) Overheat: one or more gpus overheated"

    #/opt/ethos/bin/r # <= ethOS command to reboot

else
    echo "${GREEN}[ OK ]${NC} NO OVERHEAT DETECTED"
fi

sleep 0.3

# Restart miner if hashrate missed or 0
#if [[ "${hashRate_int}" = "0"  || "${hashRate_int}" -lt "${MIN_HASH}" ]];
if [[ "${hashRate}" = "0"  || "${hashRate}" -lt "${MIN_HASH}" ]];
then
    echo "${RED}[ FAIL ]${NC} HASHARTE MISSMATCH - TRYING TO RESTART MINER";

    # Write  reboots to logfile
    echo `date +%d.%m.%Y_%H:%M:%S`  "Miner (${miner}) has restarted during hashrate missmatch. Total hashrate was: ${hashRate} hash (hashes per GPU: ${miner_hashes}). Your MIN_HASH is ${MIN_HASH}. Total uptime was: ${human_uptime}" >> /var/log/rigcheck.log

    notify "Miner (${miner}) on Rig ${worker} (${RIGHOSTNAME}) has restarted during missmatch. Total hashrate was: ${hashRate} hash (hashes per GPU: ${miner_hashes}). Your MIN_HASH is ${MIN_HASH}. Total uptime was: ${human_uptime}"

    #/opt/ethos/bin/minestop

    # Its better to restart rig on this error
    /opt/ethos/bin/r # <= ethOS command to reboot

else
    echo "${GREEN}[ OK ]${NC} HASHRATE SEEMS TO BE OK. ${hashRate} hash"
fi

sleep 0.3

if [ -n "${miner_stall}" ];
then
    echo "${RED}[ FAIL ]${NC} Miner stall: possible miner stall: check miner log";

    # Write  reboots to logfile
    echo `date +%d.%m.%Y_%H:%M:%S`  "Miner stall: possible miner stall: check miner log" >> /var/log/rigcheck.log

    notify "Rig ${worker} (${RIGHOSTNAME}) has rebooted during MINER STALL. Miner has been working for a while, but hash is zero. Total uptime was: ${human_uptime}"

    # Its better to restart rig on this error
    /opt/ethos/bin/r # <= ethOS command to reboot

else
    echo "${GREEN}[ OK ]${NC} NO POSSIBLE MINER STALL DETECTED"
fi

sleep 0.3


#### PASS TESTINGS ####

### SOME TESTS ###
echo ""
echo "${GREEN}##### VISUAL CONTROL #####${NC}";
echo "STRATUM: ${stratum_check}";
echo "MINER: ${miner} ${miner_version}";
echo "TOTAL HASH: ${hashRate} hash";
echo "YOUR MIN HASH: ${MIN_HASH} hash";
echo "HASHES PER GPU: ${miner_hashes}";
echo "MEM PER GPU: ${gpu_mem}";
echo "GPUs: ${gpus}";
echo "DRIVER: ${driver}";
echo "FAN RPM: ${fanrpm}";
echo "UPTIME: ${human_uptime}";
echo "AUTO REBOOTS ${auto_reboots}"
echo "${GREEN}##### VISUAL CONTROL END #####${NC}";

echo ""
echo "${worker} seems to work properly since ${human_uptime}."
echo ""
