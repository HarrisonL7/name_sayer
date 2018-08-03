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

mkdir -p Data

list() {


	# check if there are no creations
	if [ -z "$(ls -A Data)" ]; then

		#if so, notify the user
		printf "\nNo creations exist\n\n"
		
	else 

		# otherwise loop through folder and list contents
		count=1
		for dir in Data/*; do
			printf "$count. "

			name= basename $dir
			printf "$name"

			let count++
		done
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
		read  -p "Enter a name for your creation:" name
			
			# if name doesn't exist, create it
			if [ ! -d Data/$name ]; then
				mkdir -p Data/"$name"; break
			fi
			printf "\n	Creation already exists, please try another name.\n\n"
	done 


	# generate text video
	ffmpeg -f lavfi -i color=c=black:s=320x240:d=5 -vf \
	"drawtext=fontfile=/path/to/font.ttf:fontsize=28: \
 	fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:text='$name'" \
	Data/"$name"/"$name"_video.mp4 2> /dev/null


	# begin recording proces
	recording=true
	while $recording; do

		# ask user to press any key to begin recording audio
		read -n 1 -s -r -p "\nPress any key to continue"

		# record audio for 5 seconds
		printf "\nrecording audio...\n"
		ffmpeg -f alsa -i default -t 5 Data/"$name"/"$name"_audio.mp3 2> /dev/null

		# ask user if they want to hear the audio
		while true; do
			read  -p "Do you wish to hear the recorded audio [y/n]? :" yn

			case $yn in 
				[Yy] | [Yy][Ee][Ss] ) printf "playing\n";
				ffplay -autoexit -i Data/"$name"/"$name"_audio.mp3 2> /dev/null; break;;

				[Nn] | [Nn][Oo] ) recording=false; break;;
				* ) printf "\n 	Selection invalid, please try again.\n\n";;
			esac
		done

		# ask user if they want to keep or redo the audio
		while true; do
			read -p "\nDo you want to (k)eep or (r)edo the audio? [k/r]? : " kr

			case $kr in
				[Kk] | [Kk][Ee][Ee][Pp] ) printf "keeping\n";recording=false;break;;
				[Rr] | [Rr][Ee][Dd][Oo] ) printf "redoing\n";recording=true;break;;
				* ) printf "\n 	Selection invalid, please try again.\n\n";;
			esac

		done

	done
	
	
	#combine audio and video
	ffmpeg -i Data/"$name"/"$name"_video.mp4 -i Data/"$name"/"$name"_audio.mp3 -filter_complex\
	amix=inputs=2 Data/"$name"/"$name"_merged.mkv

	#remove audio and video files
	rm -f Data/"$name"/"$name"_video.mp4 Data/"$name"/"$name"_audio.mp3
}

selecting= true

#ask user for action, keep repeating until program is quit
while $selecting; do
	read  -p "Enter a selection [l/p/d/c/q]: "selection

		case $selection in 
			[Ll] | [Ll][Ii][Ss][Tt] ) list;;
			[Pp] | [Pp][Ll][Aa][Yy] ) play;;
			[Dd] | [Dd][Ee][Ll][Ee][Tt][Ee] ) delete;;
			[Cc] | [Cc][Rr][Ee][Aa][Tt][Ee] ) create;;
			[Qq] | [Qq][Uu][Ii][Tt] ) printf "Thank you for using NameSayer!\n\n";exit 0;break;;
			* ) printf "\n 	Selection invalid, please try again.\n\n";;
		esac
done


