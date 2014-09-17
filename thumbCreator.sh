#!/bin/bash

### Info ### 
# The script takes screenshots of the first movie in subdirectories of the current directory
# It creates a directory /thumb_<<resulution>> in the subdirectory to save the images
# Starting point, interval and resolution of the images can be defined
# from v 0.2.1 the script creates an overview xml in the start folder and index xml in the thumb folder

### Needed ### 
# avconv ==> fork of ffmpeg (because ffmpeg was depreciated for Ubuntu 14.04)

### Configuration ### 
STARTSHOT=0 		      # timestamp of the first screenshot in sec.
INTERVAL=300	        # interval between the shots
RESOLUTION="640x360" 	# Resolution of the output thumbnails 320x180

echo "********** thumbCreator ***********"

mkdir output
cd output
start_dir=$(pwd)
echo "starting directory: "$start_dir

# define movie directory
read -e -p "Enter Path to movie root directory: " -i "/home/ingo/shares/NAS/Filme" movie_dir
echo $movie_dir

# create base xml to collect all thumb-information
touch mainThumbs.xml
echo '<?xml version="1.0" encoding="UTF-8"?>' >> mainThumbs.xml
echo "<main>" >> mainThumbs.xml

# create an array of all movie sub-direcorys and loop through
cd "${movie_dir}"
dirs=( $(find . -maxdepth 2 -type d -printf '%P\n') )
echo "number of subdirectories: "${#dirs[@]}
for path in "${dirs[@]}"
  do
    echo ""
    cd "${movie_dir}"
    cd "${path}"
    echo "******** subdirectory: "$(pwd)" : "$path"  ********"
      # Take the first matching file in the current directory
      filename="$(ls *.mp* | head -1)"
      # perform only if there is any video file
      if [ -n "$filename" ]; then
        # create subdir for saving the thumbs 
        thumbfolder="${filename%.*}"
        thumbfolder=$(echo $thumbfolder | tr -d ' ')
        targetfolder="$start_dir/$thumbfolder"
        
        echo $targetfolder
        if [ ! -d $targetfolder ]; then
          mkdir $targetfolder

          target_xml="$targetfolder/titleThumbs.xml"
          # create thumbs index file in thumbs folder
          touch $target_xml
          echo '<?xml version="1.0" encoding="UTF-8"?>' >> $target_xml
          echo "<main>" >> $target_xml

          # reference thumbs file in the mainThumbs.xml
          echo "<thumbs>" >> $start_dir/mainThumbs.xml
            echo "$target_xml" >> $start_dir/mainThumbs.xml
          echo "</thumbs>" >> $start_dir/mainThumbs.xml

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
            #ffprobe -select_streams v -show_frames "$filename" 
            #avconv -an -ss $counter -i "$filename" -vsync 1 -r 1 -an -y -s $RESOLUTION "$targetfolder/$counter.jpg"
            avconv -an -ss $counter -t 0.01 -i "$filename" -ss 00:00:02 -vframes 1 -s $RESOLUTION "$targetfolder/$counter.jpg" >/dev/null 2>&1
            #avconv -an -ss $counter -t 0.01 -i "$filename" -s $RESOLUTION "$targetfolder/$counter.jpg" >/dev/null 2>&1
            #avconv: an=without audio; ss=start position; t=length; i=input; -ss 00:00:03 -vframes 1; s=thumbnail size

            #note shot in xml
            
            echo "<chapter>" >> $target_xml
              echo "<time>" >> $target_xml
                echo $counter >> $target_xml
              echo "</time>">> $target_xml
              echo "<img>" >> $target_xml
                echo "$targetfolder/$counter.jpg" >> $target_xml
              echo "</img>">> $target_xml
            echo "</chapter>" >> $target_xml

            # set counter to next shot position interval in sec.   
            let counter=counter+INTERVAL
          done
          echo "</main>" >> $target_xml
          echo "$(tput setaf 2)Thumbs created!$(tput setaf 7)"
        else
          echo "$(tput setaf 3)Thumbs directory already exists$(tput setaf 7)"
        fi
      else
        echo "$(tput setaf 1)No video files found in subdirectory$(tput setaf 7)"
      fi
  done
cd "${start_dir}"
cd ..
echo "</main>" >> $start_dir/mainThumbs.xml