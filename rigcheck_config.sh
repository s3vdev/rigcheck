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
#
# Telegram Notification (optional):
# Get status messages directly from your mining rigs if some errors occurred.
#
# 1. Open your Telegram App
# 2. GLOBAL SEARCH -> BotFather
# 3. Create a new bot by typing/clicking /newbot
# 4. Choose a user-friendly name for your bot, for example: awesomebot
# 5. Choose a unique username for your bot (must end with bot )
# 6. copy your <TOKEN> e.g. 43XXXXXX82:AAGRZjsXXXXXXXXXXlcPeyl1njlxIy60yg
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
# You can send donations to any of the following addresses:
# BTC:  1Py8NMWNmtuZ5avyHFS977wZWrUWBMrfZH
# ETH:  0x8e9e03f6895320081b15141f2dc5fabc40317e8c
# BCH:  19sp8nSeDWN4FGrKSoGKdbeSgijGW8NBh9
# BTCP: ﻿b1CCUUdgSXFkg2c65WZ855HmgS4jsC54VRg
#
# ENJOY!
###################################################################################

### BEGINN EDIT ###

# REBOOT IF THERE ARE MORE THEN X MINER RESTARTS WITHIN 1H
RebootMaxRestarts="";

# Min hash per GPU
MIN_HASHRATE_GPU="";

# If your hashrate is less than MIN_HASH, your miner will restart automatically
MIN_TOTAL_HASH="";

# IF your wattage is less than LOW_WATT, your miner will restart automatically
LOW_WATT="80";


# Telegram Gateway Service
TOKEN="";
CHAT_ID="";


# Pushover.net Gateway Service
APP_TOKEN="";
USER_KEY="";

# Cron has diff env, some paths aren't found. adjust
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/ethos/bin:/opt/ethos/sbin
### END EDIT ###