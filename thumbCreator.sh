#!/bin/bash

### Info ### 
# The script takes screenshots of the first movie in subdirectories of the current directory
# It creates a directory /thumb_<<resulution>> in the subdirectory to save the images
# Starting point, interval and resolution of the images can be defined

### Needed ### 
# avconv ==> fork of ffmpeg (because ffmpeg was depreciated for Ubuntu 14.04)

### Configuration ### 
STARTSHOT=0 		      # timestamp of the first screenshot in sec.
INTERVAL=30 		      # interval between the shots
RESOLUTION="640x360" 	# Resolution of the output thumbnails 320x180

echo "********** thumbCreator ***********"

start_dir=$(pwd)
echo "starting directory: "$start_dir

# create an array of all sub-direcorys and loop through
dirs=( $(find . -maxdepth 2 -type d -printf '%P\n') )
echo "number of subdirectories: "${#dirs[@]}
for path in "${dirs[@]}"
  do
    echo ""
    cd "${path}"
    echo "******** subdirectory: "$path" ********"
      # Take the first matching file in the current directory
      filename=$(ls *.m* | head -1)
      # perform only if there is any video file
      if [ -n "$filename" ]; then
        # create subdir for saving the thumbs  
        if [ ! -d ./thumbs_$RESOLUTION/ ]; then
          mkdir thumbs_$RESOLUTION/
          # Get movie length from file
          ff=$(avconv -i "$filename" 2>&1)
          d="${ff#*Duration: }"
          length="${d%%,*}"
          # convert time hh:mm:ss.mmm to ss.mmm
          length_sec=$(echo $length | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
          # convert time ss.mmm to ss
          length_sec_int=$(echo $length_sec | awk '{ split($0,a,"."); print a[1] }')
          # Set starting point for next movie
          counter=$STARTSHOT
          # Loop until end of movie is reached
          while [ $counter -lt $length_sec_int ] 	
            do
            # take a shot
            avconv -an -ss $counter -t 0.01 -i "$filename" -s $RESOLUTION "thumbs_$RESOLUTION/$counter.jpg" >/dev/null 2>&1
            #avconv: an=without audio; ss=start position; t=length; i=input; s=thumbnail size
            # set counter to next shot position interval in sec.   
            let counter=counter+INTERVAL
          done
          echo "$(tput setaf 2)Thumbs created!$(tput setaf 7)"
        else
          echo "$(tput setaf 3)Thumbs directory already exists$(tput setaf 7)"
        fi
      else
        echo "$(tput setaf 1)No video files found in subdirectory$(tput setaf 7)"
      fi
    cd "${start_dir}"
  done