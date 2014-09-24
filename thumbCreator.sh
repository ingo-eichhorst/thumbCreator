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
RESOLUTION="320x180" 	# Resolution of the output thumbnails 320x180

echo "********** thumbCreator ***********"

mkdir output
cd output
start_dir=$(pwd)
echo "starting directory: "$start_dir

# define movie directory
read -e -p "Enter Path to movie root directory: " -i "/home/ingo/shares/NAS/Filme/csg-movies/example" movie_dir
echo $movie_dir

# create base xml to collect all thumb-information
touch mainThumbs.xml
echo '<?xml version="1.0" encoding="UTF-8"?>' >> mainThumbs.xml
echo "<main>" >> mainThumbs.xml

# create an array of all movie sub-direcorys and loop through
cd "${movie_dir}"
dirs=( $(find . -maxdepth 1 -type d -printf '%P\n') )
echo "number of subdirectories: "${#dirs[@]}
for path in "${dirs[@]}"
  do
    echo ""
    cd "${movie_dir}"
    cd "${path}"
    echo "******** subdirectory: "$(pwd)" : "$path"  ********"
      # Take the first matching file in the current directory
      filename="$(ls *360_180*.mp* | head -1)"
      # perform only if there is any video file
      if [ -n "$filename" ]; then
        # create subdir for saving the thumbs 
        thumbfolder="${path}"
        thumbfolder=$(echo $thumbfolder | tr -d ' ')
        targetfolder="$start_dir/$thumbfolder/chapter_pics_$thumbfolder/"
        
        echo $targetfolder
        if [ ! -d $targetfolder ]; then
          mkdir -p $targetfolder

          # reference thumbs file in the mainThumbs.xml
          # start 
          echo "<title>" >> $start_dir/mainThumbs.xml
            echo "<content_id>$thumbfolder</content_id>" >> $start_dir/mainThumbs.xml

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
            # take the first shot at minute 1 - because 0 is mostly black
            if [ $counter == 0 ]; then
              shotposition=60
            else
              shotposition=$counter
            fi
            # take a shot
            filename_shot="$thumbfolder"\_"$counter"
            avconv -an -ss $shotposition -t 0.01 -i "$filename" -ss 00:00:02 -vframes 1 -s $RESOLUTION "$targetfolder/$filename_shot.jpg" >/dev/null 2>&1

            # note shot in xml
            echo "<chapter>" >> $start_dir/mainThumbs.xml
              echo "<time_sec>" >> $start_dir/mainThumbs.xml
                echo $counter >> $start_dir/mainThumbs.xml
              echo "</time_sec>">> $start_dir/mainThumbs.xml
              echo "<img_shot_sec>" >> $start_dir/mainThumbs.xml
                echo $shotposition >> $start_dir/mainThumbs.xml
              echo "</img_shot_sec>">> $start_dir/mainThumbs.xml
              echo "<img>" >> $start_dir/mainThumbs.xml
                echo "$targetfolder/$filename_shot.jpg" >> $start_dir/mainThumbs.xml
              echo "</img>">> $start_dir/mainThumbs.xml
            echo "</chapter>" >> $start_dir/mainThumbs.xml

            # set counter to next shot position interval in sec.   
            let counter=counter+INTERVAL
          done
          echo "</title>" >> $start_dir/mainThumbs.xml
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