<?php
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
#
# 1. Just edit your email and your token (a secret word/passphrase)
# 2. upload this file to any php webspace and insert your url and your token on rigcheck_config.sh
# optional: create a file called logs.txt and chmod 777 itself
#
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

// Begin edit
$your_token = ""; // a secret word or passphrase
$email = ""; // your email to receive status message via email
// END edit



// Posted vars from ethOS rig
$token = $_POST['token'];
$text = $_POST['text'];
$rig  = $_POST['rig'];

// Check if posted token from your ethOS rig similar to your_token
if ($your_token == $token)
{
    // Mail send
    $subject = "rigcheck - new execution on rig $rig detected";
    $header  = "From: rigcheck <notify@'.$rig>\n";
    $header .= "Content-Type: text/html\n";
    $header .= "X-Mailer: PHP ". phpversion();
    mail($email, $subject, $text, $header);


    // Write log
    $log  = "Date: ".$_SERVER['REMOTE_ADDR'].' - '.date("F j, Y, g:i a") . PHP_EOL.
            "E-Mail: " . $email . PHP_EOL.
            "Rig: " . $rig . PHP_EOL.
            "Reason: " . $text . PHP_EOL.
            "-------------------------" . PHP_EOL;

    file_put_contents('logs.txt', $log . PHP_EOL , FILE_APPEND | LOCK_EX);
}