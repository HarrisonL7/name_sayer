#!/bin/bash
clear
printf "==============================================================\n"
printf "		  Welcome to NameSayer\n"
printf "==============================================================\n"
printf "\n"
printf "Please select from one of the following options:\n"
printf "\n"
printf "	(l)ist existing creations\n"
printf "	(p)lay an existing creation\n"
printf "	(d)elete an existing creation\n"
printf "	(c)reate a new creation\n"
printf "	(q)uit authoring tool\n"
printf "\n"

list() {

	DATA=Data

	# check if any creations exist
	if [ "$ls -A $DATA" ]; then

		# if so, loop through folder and list contents
		count=0
		for dir in Data/*; do
			let count++
			printf "$count. "

			name= basename $dir
			printf "$name"

			
		done

	else 
		#otherwise, notify user
		printf "No creations exist"
	fi


}

play() {
	printf "played\n"
}

delete() {
	printf "deleted\n"
}
 
create() {

	#repeatedly asks the user for a valid name
	while true; do
		invalid=false
		read  -p "Enter a name for your creation:" name
			if [ ! -d Data/$name ]; then
				break
			fi
			printf "creation already exists\n"
	done 



	

	mkdir -p Data/"$name"

	# generate video
	ffmpeg -f lavfi -i color=c=black:s=320x240:d=5 -vf \
	"drawtext=fontfile=/path/to/font.ttf:fontsize=30: \
 	fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:text='$name'" \
	Data/"$name"/"$name"_video.mp4

	recording=true
	while $recording; do

		# ask user to press any key to begin recording audio
		read -n 1 -s -r -p "Press any key to continue"

		# record audio for 5 seconds
		printf "\nrecording audio...\n"
		ffmpeg -f alsa -i pulse -f alsa -i default -t 00:00:05 Data/"$name"/"$name"_audio.wav

		while true; do
			read  -p "Do you wish to hear the recorded audio (y/n):" yn
			case $yn in 
				[Yy]* ) printf "playing\n";ffplay -autoexit -i out.wav; break;;
				[Nn]* ) recording=false; break;;
				* ) printf "Selection invalid\n";;
			esac
		done

		while true; do
			printf "Do you want to:\n";
			printf "(k)eep the audio?\n";
			printf "(r)edo the audio?\n";
			read  -p "Enter option:" kr;

			case $kr in
				[Kk]* ) printf "keeping\n";recording=false;break;;
				[Rr]* ) printf "redoing\n";recording=true;break;;
				* ) printf "Selection invalid\n";;
			esac

		done

	done
	
	#combine audio and video


	printf "created\n"
}

selecting= true

#ask user for input
while $selecting; do

	read  -p "Enter a selection [l/p/d/c/q]:" selection
		case $selection in 
			[Ll]* ) list;;
			[Pp]* ) play;;
			[Dd]* ) delete;;
			[Cc]* ) create;;
			[Qq]* ) printf "Thank you for using NameSayer!\n";exit 0;break;;

			* ) printf "Selection invalid\n";;
		esac
done


