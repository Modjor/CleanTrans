#!/bin/sh
# Clean Transmission Torrent list depending of the status
# Configure trremote, truser and trpsw below

# Path to transmission-remote
trremote=/volume1/@appstore/transmission/bin/transmission-remote

# Transmission User and Password
truser=""
trpsw=""



# get ratio limit value
RATIOLIMIT=`$trremote --auth=$truser:$trpsw -si | grep "Default seed ratio limit:" | cut -d \: -f 2`

# get torrent list from transmission-remote list
# delete first / last line of output
# remove leading spaces
# get first field from each line
TORRENTLIST=`$trremote --auth=$truser:$trpsw --list | sed -e '1d;$d;s/^ *//' | cut -s -d " " -f1`

# for each torrent in the list
for TORRENTID in $TORRENTLIST
do
echo "* * * * * Operations on torrent ID $TORRENTID starting. * * * * *"
    
    # check if torrent was started
    STARTED=`$trremote --auth=$truser:$trpsw --torrent $TORRENTID --info | grep "Id: $TORRENTID"`
    # echo " - started state = $STARTED" # debug message
    
    # check if torrent download is completed
    COMPLETED=`$trremote --auth=$truser:$trpsw --torrent $TORRENTID --info | grep "Percent Done: 100%"`
    # echo " - completed state = $COMPLETED" # debug message
    
    # check torrent's current state is "Stopped"
    STOPPED=`$trremote --auth=$truser:$trpsw --torrent $TORRENTID --info | grep "State: Finished"`
    # echo " - torrent stopped seeding = $STOPPED" # debug message
    
    # check to see if ratio-limit-enabled is true
    if [ "$RATIOLIMIT" != "Unlimited" ]; then
        # check if torrent's ratio matches ratio-limit
        CAPPED=`$trremote --auth=$truser:$trpsw --torrent $TORRENTID --info | grep "Ratio: $RATIOLIMIT"`
    fi

  # if the torrent is "Stopped" after downloading 100% and seeding, move the files and remove the torrent from Transmission
  
  if [ "$COMPLETED" != "" ] ; then
echo "Torrent #$TORRENTID is completed."
    echo "Removing torrent from list."
    $trremote --auth=$truser:$trpsw --torrent $TORRENTID --remove
  else
echo "Torrent #$TORRENTID is not completed. Ignoring."
  fi

echo "* * * * * Operations on torrent ID $TORRENTID completed. * * * * *"

done
