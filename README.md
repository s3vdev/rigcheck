### rigcheck v.1.0.16 (March 2018) based on ethOS 1.3.x by Sven Mielke ###
  
If you have any errors in your ethOS rigcheck will restart your miner or reboot your system.
With Telegram and Pushover.net realtime notifications. 

![Showcase](https://i.imgur.com/UIWksVN.jpg)

### UPDATES ###
##
##### v1.0.16 - 2018/03/18 #####
+ Added install.sh script to automatically install rigcheck on your ethOS mining rig
+ Added new check features


##
##### v1.0.15 - 2018/03/14 #####
+ User configuration vars are outsourced to rigcheck.config for NEW rigcheck_autoupdater.sh 
+ Added a fresh new autoupdater script, to get rigcheck updates automatically, if a new version is found on this repository. 

##
##### v1.0.14 - 2018/03/12 #####
+ Add watts check (best way to detect crash for Nvidia cards) (Thanks to Min Min)
+ Fixing a problem with hashrate decimal values. Rounding to INT. (Thanks to Lukas Martin)
+ Fixed a problem with Uptime in minutes not being processed correctly. Using total seconds from uptime. (Thanks to Lukas Martin)

##
### Install rigcheck.sh to ethos ###
Install rigcheck in two ways:

+ Automatically via *install.sh* script or
+ Manually

Connect to you mining rig (via Filezilla SFTP or via SSH). 
User: ethos, Pass: live

#### via Filezilla: ####
1. Navigate to /home/ethos
2. Upload rigcheck.sh AND rigcheck_config.sh to that directory
3. Change chmod to 755
4. Open your SSH terminal via Putty or any other ssh client
5. Type "sudo crontab -e"
6. Insert: "*/5 * * * * /home/ethos/rigcheck.sh"
7. Edit your vars in rigcheck_config.sh
8. Finished!

#### via SSH: ####
1. nano rigcheck.sh
2. Copy & paste the complete script from rigcheck.sh
3. CMD + X (mac) or STRG + X (Win) to save and close
4. Repeat this step with rigcheck_config.sh
5. Type: "chmod a+x rigcheck.sh" and "chmod a+x rigcheck_config.sh"
6. Create a cronjob: "sudo crontab -e"
7. Insert: */5 * * * * /home/ethos/rigcheck.sh
8. Edit your vars in rigcheck_config.sh
9. Finished!

#### via install.sh script: ####
1. Download install.sh to your /home/ethos folder
2. Type "chmod a+x install.sh"
3. Run "bash install.sh"
4. Answer the question
5. Finished!


#### rigcheck_config.sh (necessary only on manual install) ####
```
#### Notifications / Pushnotifications ####

#### TELEGRAM ####
1. Open your Telegram App
2. GLOBAL SEARCH -> BotFather
3. Create a new bot by typing/clicking /newbot
4. Choose a user-friendly name for your bot, for example: awesomebot
5. Choose a unique username for your bot (must ends with â€œbotâ€)
6. copy your TOKEN e.g. 4334584910:AAEPmjlh84N62Lv3jGWEgOftlxxAfMhB1gs
7. Start a conversation with your bot: GLOBAL SEARCH -> MY_BOT_NAME -> START
8. To get the chat ID, open the following URL in your web-browser: https://api.telegram.org/bot[TOKEN]/getUpdates
9. copy your chat id in var CHAT_ID and your token to TOKEN below


#### Pushover.net - Push notification gateway ####
Get push notifications to your iOS, Android or Windows Phone or Tablet.
Just register your free account and application and get all status message from ethOS to your Phone.
Please edit this new variables to activate push notification services: 

RebootMaxRestarts="5";

MIN_HASHRATE_GPU="20";

MIN_TOTAL_HASH="90";

LOW_WATT="80";

TOKEN="43XXXXXX82:AAGRZjsXXXXXXXXXXlcPeyl1njlxIy60yg";

CHAT_ID="2XXXXXXX34";

APP_TOKEN="";

USER_KEY=""; 
```

##
### Usage ###

If you setup your cronjob, rigcheck.sh will run and check some conditions every 5 minutes. If any soft error is located, your miner will be restarted (minestop). On some conditions like adl_error, GPU error your rig will be 
rebooted automatically. In addition, each miner restart or rig reboot is logged in /home/ethos/rigcheck.log with date and time and error.

### Optional scripts ###
 
##
> #### rigcheck_autoupdater.sh ####
> Download rigcheck_autoupdater.sh to /home/ethOS to get automatically updates and notifications, if a new version of rigcheck is found in this repository.
> If you wish to get automatically updates just edit only ONE var:
> 
> ``` autoUpdate="yes"; ```
> 
> Set chmod
> 
> ``` chmod a+x /home/ethos/rigcheck_autoupdater.sh ```
> 
> Run as cronjob, every day at 0pm
> 
> ``` sudo crontab -e ```
> 
> 
> ``` 0 0 * * * /home/ethos/rigcheck_autoupdater.sh ```
> 

##
> #### rigcontrol.sh - Telegram Bot ####
> If you wish that you can control your ethOS Mining Rig than download rigstatuscontrol.sh and rigcontrol.sh to your folder /home/ethOS to manage your rig via Telegram Messenger.
> 
> ![Showcase](https://i.imgur.com/GESZMmV.jpg)
> 
> See it in action: https://vimeo.com/260455169
> 
> Install Video: https://vimeo.com/260577442
> 
> Repository: https://bitbucket.org/s3v3n/rigcontrol
> 

##
> #### update_rigcheck.sh (old) ####
> This little shell script helps you to update ALL your ethos mining rigs with rigcheck.sh and rigcheck_config.sh by enter only one command to your terminal.
>
> See it in action: https://vimeo.com/260760489
> 

##
> #### filecopy.sh (new) ####
> ![Showcase](https://i.imgur.com/w8fq7uM.png)
> This little shell script helps you to copy a file to ALL your ethos mining rigs by enter only one command to your terminal.
>
> See it in action: https://vimeo.com/260784823
> 


##
#### Testing rigcheck ####
Try bash, calling sh make bash switch to posix mode and gives you some error

``` bash /home/ethos/rigcheck.sh ```

Your results will be like this:
```
STATUS OK: GPU[0] HASH:24.72 WATTS:105 CORE:1746 MEM:4666 FANRPM:3150
STATUS OK: GPU[1] HASH:24.71 WATTS:104 CORE:1771 MEM:4666 FANRPM:3150
STATUS OK: GPU[2] HASH:24.70 WATTS:106 CORE:1797 MEM:4666 FANRPM:3150
STATUS OK: GPU[3] HASH:24.71 WATTS:104 CORE:1809 MEM:4666 FANRPM:3150
STATUS OK: NO GPU CLOCK PROBLEM DETECTED
STATUS OK: NO GPU CRASH DETECTED
STATUS OK: NO GPU LOST DETECTED
STATUS OK: FAN RPM SEEMS TO BE OK
STATUS OK: POWER CABLE SEEMS TO BE OKAY AND WORKING
STATUS OK: NO HARDWARE ERROR DETECTED
STATUS OK: NO GPUS OVERHEATED
STATUS OK: TOTAL HASHRATE SEEMS TO BE OK. 98.83 (INT 98) hash
STATUS OK: NO POSSIBLE MINER STALL DETECTED

##### VISUAL CONTROL #####
STRATUM: enabled
MINER: claymore v11.5
 running for 5h:54m:51s
TOTAL HASH: 98.83 hash
YOUR MIN HASH:  hash
GPUs: 4
DRIVER: nvidia
AUTO REBOOTS 3
REBOOT ON TO MANY MINER RESTARTS: 0/5
##### VISUAL CONTROL END #####

Rig rig2 seems to work properly since 5 hours, 57 minutes.
```

Enjoy!







