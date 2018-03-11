# rigcheck v.1.0.10 (March 2018) based on ethOS 1.3.x by Sven Mielke #
  
If you have any errors in your ethOS rigcheck will restart your miner or reboot your system.
Include with Telegram or Pushover.net Notifications. 

![Showcase](https://i.imgur.com/UIWksVN.jpg)


### Install rigcheck.sh to ethos ###

Connect to you mining rig (directly or via ssh).
 
cd /home/ethos

```nano rigcheck.sh```

copy&paste the content from rigcheck.sh OR upload rigcheck.sh directly to your rig in /home/ethos

```chmod a+x rigcheck.sh```

Create an cronjob to and let your script run every 5m.

```sudo crontab -e```

Insert the following line for run cronjob every 5 mins:

```*/5 * * * * /home/ethos/rigcheck.sh```

Open rigcheck.sh and set your vars like min hash and/or telegram/pushover notification

```MIN_HASH="0"```

Finish


### Usage ###

rigcheck.sh will run every x minute via cronjob. If is any error located, your miner will be reatarted or rig will be 
rebooted automatically. 
In addition, each miner restart or rig reboot is logged in /var/log/righeck.log with date and time.
Enjoy!
  

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


