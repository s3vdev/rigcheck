# rigcheck v.1.0.15 (March 2018) based on ethOS 1.3.x by Sven Mielke #
  
If you have any errors in your ethOS rigcheck will restart your miner or reboot your system.
Include with Telegram and Pushover.net notifications. 

![Showcase](https://i.imgur.com/UIWksVN.jpg)

### UPDATES ###
##### v1.0.14 - 2018/03/12 #####
+ Add watts check (best way to detect crash for Nvidia cards) (Thanks to Min Min)
+ Fixing a problem with hashrate decimal values. Rounding to INT. (Thanks to Lukas Martin)
+ Fixed a problem with Uptime in minutes not being processed correctly. Using total seconds from uptime. (Thanks to Lukas Martin)

### Install rigcheck.sh to ethos ###

Connect to you mining rig (directly or via ssh).
 
cd /home/ethos

```nano rigcheck.sh```

copy&paste the content from rigcheck.sh OR upload rigcheck.sh directly to your rig in /home/ethos

```chmod a+x rigcheck.sh```

Create an cronjob to and let your script run every 5m.

```sudo crontab -e```

Insert the following line to run cronjob every 5 minutes:

```*/5 * * * * /home/ethos/rigcheck.sh```

Open rigcheck.sh and set your vars like MIN_HASH or LOW_WATT and Telegram or Pushover vars (or booth) to get instant notifications.

``` MIN_HASH="0" ```

``` LOW_WATT="0" ```

Finish :-)


### Usage ###

rigcheck will run for example every 5 minutes via cronjob. If any soft error is located, your miner will be reatarted or rig will be 
rebooted automatically. 
In addition, each miner restart or rig reboot is logged in /var/log/rigcheck.log with date and time.
Enjoy!
  
#### Testing #### 
Try bash, calling sh make bash switch to posix mode and gives you some error

``` bash /home/ethos/rigcheck.sh ```

Your results will be like this:
``` 
[ OK ] NO GPU CLOCK PROBLEM DETECTED
[ OK ] NO GPU CRASH DETECTED
[ OK ] NO GPU LOST DETECTED
[ OK ] FAN RPM SEEMS TO BE OK
[ OK ] POWER CABLE SEEMS TO BE OKAY AND WORKING
[ OK ] NO HARDWARE ERROR DETECTED
[ OK ] NO OVERHEAT DETECTED
[ OK ] HASHRATE SEEMS TO BE OK. 24.16 (INT 24) hash
[ OK ] NO POSSIBLE MINER STALL DETECTED
[ OK ] GPU WATTAGE SEEMS TO BE OK


##### VISUAL CONTROL #####
STRATUM: enabled
MINER: claymore v11.0
TOTAL HASH: 24.16 hash
YOUR MIN HASH:  hash
GPUs: 1
DRIVER: nvidia
HASHES PER GPU: 24.16
MEM PER GPU: 4576
WATTS: 96
FAN RPM: 3150
UPTIME: 34 minutes
AUTO REBOOTS 3
##### VISUAL CONTROL END #####
```



### Get status messages directly from your mining rigs if some errors occurred. ###

### TELEGRAM ###
1. Open your Telegram App
2. GLOBAL SEARCH -> BotFather
3. Create a new bot by typing/clicking /newbot
4. Choose a user-friendly name for your bot, for example: awesomebot
5. Choose a unique username for your bot (must ends with â€œbotâ€)
6. copy your TOKEN e.g. 4334584910:AAEPmjlh84N62Lv3jGWEgOftlxxAfMhB1gs
7. Start a conversation with your bot: GLOBAL SEARCH -> MY_BOT_NAME -> START
8. To get the chat ID, open the following URL in your web-browser: https://api.telegram.org/bot[TOKEN]/getUpdates
9. copy your chat id in var CHAT_ID and your token to TOKEN below

``` TOKEN="xyz" ```

``` CHAT_ID="yxz" ```



### Pushover.net - Push notification gateway ###

Get push notifications to your iOS, Android or Windows Phone or Tablet.

Just register your free account and application and get all status message from ethOS to your Phone.

Please edit this new variables to activate push notification services: 

``` APP_TOKEN="xyz" ```

``` USER_KEY="yxz" ```


