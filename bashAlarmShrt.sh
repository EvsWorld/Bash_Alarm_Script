#!/bin/bash

# Now my main problem is that this thing will wake it self up at the right time but it wont play the spotify stuff (maybe b/c it's not logged in automatically)
# This must be run as nohup, buy typing 'nohup bashAlarm.sh'

# This script seems to work well when it is in /usr/local/bin and put in readable/executable status for everyone (using chmod 755)

# To get the PID of the last command launched in your script, use $!
# PID=$!

# Somehow make it so it wont wake up unless the lid is open

# https://www.howtogeek.com/121241/how-to-make-your-linux-pc-wake-from-sleep-automatically
#
# This is the spotify bash library: https://github.com/hnarayanan/shpotify
#

# Here's an example of input validation with a while loop
# number=""
# while [[ ! $number =~ ^[0-9]+$ ]]; do
#     echo Please enter your age
#     read number
# done
# echo You are $number years old


# setTime(inputTime)
# {
#     # Temporary function stub
#     echo 'Function: setTime'
#     # setTimeEarly outputs in date format for pmset
#     setTimeEarly=$(date -j -f "%H%M" $inputTime "+%m/%d/%y %H:%M:%S")
#     # echo "setTimeEarly is: $pmsetTimeEarly"
#     #setTimeLate takes (today's) date from $inputTime in %H%M format, then adds a day, then outputs like this: %m/%d/%y %H:%M:%S"
#     setTimeLate=$(date -j -f "%H%M" -v+24H "$inputTime" "+%m/%d/%y %H:%M:%S")
#     # echo "setTimeLate is: $setTimeLate"
#     setTimeNow=$(date -j -f "%s" $(date +%s) "+%m/%d/%y %H:%M:%S")
#     # echo "setTimeNow is: $setTimeNow"
#     return "$( [[ $setTimeEarly > $setTimeNow ]] && echo "$pmsetTimeEarly" || echo "$pmsetTimeLate" )"
# }

# Validating user input:
# inputTime=""
# # echo "nextTime is: $nextTime"
# # secondsEarly gives me the date and time in seconds
# secondsEarly=$(date -j -f "%H%M" $inputTime "+%s")
# # echo "secondsEarly is: $secondsEarly"
# # setTimeEarly outputs in date format for pmset
# setTimeEarly=$(date -j -f "%H%M" $inputTime "+%m/%d/%y %H:%M:%S")
# # echo "setTimeEarly is: $pmsetTimeEarly"
# #setTimeLate takes (today's) date from $inputTime in %H%M format, then adds a day, then outputs like this: %m/%d/%y %H:%M:%S"
# setTimeLate=$(date -j -f "%H%M" -v+24H "$inputTime" "+%m/%d/%y %H:%M:%S")
# # echo "setTimeLate is: $setTimeLate"
# # secondsEarly gives me the date and time in seconds
# secondsLate=$(date -j -f "%H%M" -v+24H $inputTime "+%s")
# # echo "setTimeLate is: $setTimeLate"
# secondsNow=$(date +%s)
# # echo "secondsNow is: $secondsNow"
# setTimeNow=$(date -j -f "%s" $(date +%s) "+%m/%d/%y %H:%M:%S")
# # echo "setTimeNow is: $setTimeNow"
# [[ $setTimeEarly > $setTimeNow ]] && echo "$setTimeEarly" || echo "$setTimeLate"

# setTimeEarly outputs in date format for pmset
# setTimeEarly=$(date -j -f "%H%M" $inputTime "+%m/%d/%y %H:%M:%S")

#**************************** start ***************************

inputTime=""

while [[ ! $inputTime =~ ^((0[0-9]|1[0-9]|2[0-4])(0[0-9]|1[0-9]|2[0-9]|3[0-9]|4[0-9]|5[0-9]|60))$ ]];
do
    setTimeNow=$(date -j -f "%s" $(date +%s) "+%m/%d/%y %H:%M:%S")
    # echo "setTimeNow is: $setTimeNow"

    read -p  "Please enter the time you want to wake up in the format: HHmm. The alarm will sound at the next occurance of this time. It is now [$setTimeNow]. > " inputTime
    if [[ ! $inputTime =~ ^((0[0-9]|1[0-9]|2[0-4])(0[0-9]|1[0-9]|2[0-9]|3[0-9]|4[0-9]|5[0-9]|60))$ ]];
    then
        echo "$inputTime is not a valid format"
    else
        # What we are defining now (in seconds)
        secondsTest=$(date +%s)
        echo "secondsTest is: $secondsTest"

        # What we are defining now (formatted)
        formatedTest=$(date -j -f "%s" $secondsTest "+%m/%d/%y %H:%M:%S")


        # setTimeEarly outputs in date format for pmset
        setTimeEarly=$(date -j -f "%H%M" $inputTime "+%m/%d/%y %H:%M:%S")
        # echo "setTimeEarly is: $pmsetTimeEarly"

        #setTimeLate takes (today's) date from $inputTime in %H%M format, then adds a day, then outputs like this: %m/%d/%y %H:%M:%S"
        setTimeLate=$(date -j -f "%H%M" -v+24H "$inputTime" "+%m/%d/%y %H:%M:%S")
        # echo "setTimeLate is: $setTimeLate"

        # secondsEarly gives me the date and time in seconds
        secondsEarly=$(date -j -f "%H%M" $inputTime "+%s")
        echo "secondsEarly is: $secondsEarly"

        # secondsEarly gives me the date and time in seconds
        secondsLate=$(date -j -f "%H%M" -v+24H $inputTime "+%s")
        echo "secondsLate is: $secondsLate"

        wakeTimeSeconds=$( [[ $secondsEarly > $secondsTest ]] && echo "$secondsEarly" || echo "$secondsLate" )

        wakeTimePmset=$( [[ $secondsEarly > $secondsTest ]] && echo "$setTimeEarly" || echo "$setTimeLate" )

        secondsNow=$(date +%s)
        sleepSeconds=$(( (wakeTimeSeconds - secondsNow) + 20))
        echo "sleepSeconds is: $sleepSeconds"


        echo "Your alarm has been set for:  "$( [[ $setTimeEarly > $setTimeNow ]] && echo "$setTimeEarly" || echo "$setTimeLate" )" "



        # For pmset: "MM/dd/yy HH:mm:ss" (in 24 hour format; must be in quotes)
        sudo pmset -a schedule wakeorpoweron "$wakeTimePmset"
    fi
done

# Cancel any existing scheduled pmset/wake up settings
#sudo pmset schedule cancelall

# If the substitution appears within double quotes, word splitting and filename expansion are not performed on the results.

echo "Time right before sleep loop is: $(date -j -f "%s" $(date +%s) "+%m/%d/%y %H:%M:%S") "
while [[ $(date +%s) < $(($wakeTimeSeconds + 30)) ]];
do
    sleep 10
    echo "Time now is $(date -j -f "%s" $(date +%s) "+%m/%d/%y %H:%M:%S") (< Wake up time), so still sleeping"
done

echo "Time right after sleep loop is: $(date -j -f "%s" $(date +%s) "+%m/%d/%y %H:%M:%S") "

# sleep "$(( $sleepSeconds ))"



osascript -e 'set volume output volume 100'
spotify toggle shuffle
spotify vol 30
spotify play uri spotify:user:pacmann32:playlist:0meVJ1U3wXII6tps2xKNZ1

for i in 1 2 3 4 5 6 7 8 9 10
do
    spotify vol up
    sleep 60
done

# We will see, but if it puts itself to sleep before reaching max volume, I may need to put a caffienate statement here to force it to stay awake for a few minutes, to keep playing music until I get out of bed to turn it off.


# atInputTime=$(date -j -f "%H%M" -v+20S "$inputTime" "+%H:%M")
# echo "$atInputTime"
# # Note: The date varable for the 'at' command needs quotes
#
# { echo osascript -e 'set volume output volume 100'; echo spotify toggle shuffle; echo spotify vol 30; echo spotify play uri spotify:user:spotify:playlist:37i9dQZF1DX9OZisIoJQhG; echo for i in 1 2 3 4 5 6 7 8 9 10; echo do; echo spotify vol up; echo sleep 45; echo done; } | at $atInputTime


# echo "sleep 20; echo This should echo in commandline 1 mins after starting up. This will  prove that the script is still running after the computer wakes up due to bashAlarm.sh; osascript -e 'set volume output volume 100'; spotify toggle shuffle; spotify vol 30; spotify play uri; spotify:user:spotify:playlist:37i9dQZF1DX9OZisIoJQhG;
# for i in 1 2 3 4 5 6 7 8 9 10; do; spotify vol up; sleep 45; done"

# Kill script
# kill $PID

# The above processes should start the spotify process.
# The last thing would be to make sure that when it exits, it kills the nohup process. Or maybe that is irelevent b/c it would be impossible for it to run again after the date it was set to has passed.

# while time != $wakeTime
    # sleep 2m

############ or #############################

# at -t 201403142134.12 < script.sh
#
# read -p "Press any key to continue.." -n 1 -s

# Another cool way would be to input the spotify url as the second argument, like this.. # spotify play $2


# Other possiblity maybe would be this... but I think it's for Ubuntu
#
# (hashbang)/bin/bash
#
# # Auto suspend and wake-up script
# #
# # Puts the computer on standby and automatically wakes it up at specified time
# #
# # Written by Romke van der Meulen <redge.online@gmail.com>
# # Minor mods fossfreedom for AskUbuntu
# #
# # Takes a 24hour time HH:MM as its argument
# # Example:
# # suspend_until 9:30
# # suspend_until 18:45
#
# # ------------------------------------------------------
# # Argument check
# if [ $# -lt 1 ]; then
#     echo "Usage: suspend_until HH:MM"
#     exit
# fi
#
# # Check whether specified time today or tomorrow
# DESIRED=$((`date +%s -d "$1"`))
# NOW=$((`date +%s`))
# if [ $DESIRED -lt $NOW ]; then
#     DESIRED=$((`date +%s -d "$1"` + 24*60*60))
# fi
#
# # Kill rtcwake if already running
# sudo killall rtcwake
#
# # Set RTC wakeup time
# # N.B. change "mem" for the suspend option
# # find this by "man rtcwake"
# sudo rtcwake -l -m mem -t $DESIRED &
#
# # feedback
# echo "Suspending..."
#
# # give rtcwake some time to make its stuff
# sleep 2
#
# # then suspend
# # N.B. dont usually require this bit
# #sudo pm-suspend
#
# # Any commands you want to launch after wakeup can be placed here
# # Remember: sudo may have expired by now
#
# # Wake up with monitor enabled N.B. change "on" for "off" if
# # you want the monitor to be disabled on wake
# xset dpms force on
#
# # and a fresh console
# clear
# echo "Good morning!"
