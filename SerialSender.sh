#!/bin/bash
# 
# Serial Sender
# This is simple script to send serial data from terminal using the ttyUSB
# 
# --------------------------------------------------------------------
# This is a free shell script under GNU GPL version 2.0 or above
# Feedback/comment/suggestions : saymoncoppi@gmail.com
# Created: 26/02/2019
# -------------------------------------------------------------------------

# Get params and set vars
#######################################################################################
loop_size=$1        # Loop size determine how many data will be sended to the server
write_file=n        # Write html file (y/n)
screen_results=y    # See screen Interactions (y/n)
string_size=13      # String size to generate random number
baudrate=115200     # Use your baudrate adapter like: 9600, 19200, 38400, 57600, 115200

# Determine your base_url to write on logs
base_url="http://YOUR_BASE_URL/YOUR_API?"
# Choose the HTML file name to get logs
filename="SerialSender"-$(date '+%d%m%Y-%H%M%S')".html"  



# Starting SerialSender function
#######################################################################################
function SerialSender {
START=$(date +%s.%N)

    # Check and Create file with results?
    #######################################################################################
    if [ $write_file == y ]
    then
            if [ -e $filename ]
        then
            rm -rf $filename
            echo  "Making a new "$filename
        else
            echo  "Making a new "$filename
        fi
    fi

    # Adapter Settings 
    #######################################################################################
    # Allow write data to RS232 Adapter
    chmod o+rw /dev/ttyUSB0

    # Setup RS232 Adapter
    stty -F /dev/ttyUSB0 $baudrate raw -echo

    clear # Showing results below here

    # Creating file
    #######################################################################################
    if [ $write_file == y ]
    then
        echo  "<html>" > $filename
        echo "<H2>Created: "$(date) "</H2>" >> $filename
    fi

    # Running now
    #######################################################################################
    echo ''
    echo "Starting..."
    echo ''

    for counter in $(eval echo "{1..$loop_size..1}"); do

        # Create a random number to simulate an EAN13
        codex=$(head /dev/urandom | tr -dc 0-9 | head -c $string_size) # use tr -dc A-Za-z0-9 to generate strings

        # Screen results
        if [ $screen_results == y ]
        then
            echo "$counter - $codex " $(date +"%T:%3N");    
        fi

        # Adding data to file
        if [ $write_file == y ]
        then
            echo  "<a href='$base_url$codex' target='_blank'>$codex</a><small> ($(date +"%T:%3N"))</small><br />" >> $filename
        fi

        # Writing on RS232 Adapter
        #echo "$codex" > /dev/ttyUSB0;

        echo "idleitor=1&dados=$codex&porta=1" > /dev/ttyUSB0;

        # Closing File
        if [ $write_file == y ]
        then
            echo  "</html>" >> $filename
        fi

        # test time
        sleep 0.0001
    done
    echo ''
    echo "Done!"
    echo ''

    END=$(date +%s.%N)
    DIFF=$(echo "$END - $START" | bc)

    # Resume:
    echo "Resume:"
    echo "Elapsed time: $DIFF"
    echo "Registers: $counter"
}

SerialSender