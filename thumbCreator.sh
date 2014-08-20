#!/bin/bash

### Info ### 
# The script takes screenshots of the first movie in subdirectories of the current directory
# It creates a directory /thumb in the subdirectory to save the images
# Starting point, interval and resolution of the images can be defined

### Needed ### 
# avconv ==> fork of ffmpeg (because ffmpeg was depreciated for Ubuntu 14.04)

### Configuration ### 
STARTSHOT=0 		      # timestamp of the first screenshot in sec.
INTERVAL=30 		      # interval between the shots
RESOLUTION="320x180" 	# Resolution of the output thumbnails

startDir=`pwd`
echo $startDir

# create an array of all sub-direcorys and loop through
dirs=( $(find . -maxdepth 2 -type d -printf '%P\n') )
echo ${#dirs[@]}
for path in "${dirs[@]}"
  do
    echo $path
    cd $path
      # Take the first matching file in the current directory
      filename=`ls *.m* | head -1`
      # perform only if there is any video file
      if [ -n "$filename" ]; then
        # create subdir for saving the thumbs
        mkdir thumb/
        # Get movie length from file
        ff=$(avconv -i "$filename" 2>&1)
        d="${ff#*Duration: }"
        length="${d%%,*}"
        # convert time hh:mm:ss.mmm to ss.mmm
        lengthSec=`echo $length | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }'`
        # convert time ss.mmm to ss
        lengthSecInt=`echo $lengthSec | awk '{ split($0,a,"."); print a[1] }'`
        # Set starting point for next movie
        counter=$STARTSHOT
        # Loop until end of movie is reached
        while [ $counter -lt $lengthSecInt ] 	
          do
          # take a shot
          avconv -an -ss $counter -t 0.01 -i "$filename" -s $RESOLUTION "thumb/$counter.jpg" 
          #avconv: an=without audio; ss=start position; t=length; i=input; s=thumbnail size
          # set counter to next shot position interval in sec.   
          let counter=counter+INTERVAL		
        done
      fi
    cd $startDir
  done