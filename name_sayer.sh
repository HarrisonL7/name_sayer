#!/bin/bash

mkdir -p Data

getSelection() {

	printf " Enter (c) to cancel\n\n"
	cancelled=false

	# keep asking user for selection, until successful or cancelled
	while true; do
		read  -p "Enter the name of the creation you wish to $1: " creation

		# if user cancels, return
		if [ "$creation" = "C" ] || [ "$creation" = "c" ]; then
			printf "\n 	Cancelled $1.\n\n"; cancelled=true; return
		fi

		# replace spaces with underscores
		creation="${creation// /_}"

		# if it exists, return
		if [ -d Data/$creation ]; then
				return
		fi

		printf "\n 	That creation does not exist, please try again.\n\n"
	done
}

list() {

	empty=false

	# check if there are no creations
	if [ -z "$(ls -A Data)" ]; then

		#if so, notify the user
		printf "\nNo creations exist\n\n"
		empty=true

	else 
		# otherwise loop through folder and list contents

		printf "\n Creations: \n\n"

		count=1
		for dir in Data/*; do
			printf "	$count. "

			# get name of creation without path
			name="$(basename $dir)"

			#replace underscores with spaces
			name="${name//_/ }"

			printf "$name \n"

			let count++
		done
	fi
	printf "\n"

}

play() {

	# list all creations
	list

	# if list is empty return to main menu 
	if $empty; then
		return
	fi

	#select a creation
	getSelection "play"

	# if the user has cancelled return to the main menu
	if $cancelled; then
		return
	fi

	# if user has selected, play selection
	printf "\nPlaying... \n"
	ffplay -loglevel quiet -autoexit -i Data/"$play"/"$play"_merged.mkv

}

delete() {
	#list all creations
	list

	# if list is empty return to main menu 
	if $empty; then
		return
	fi

#	select a creation
	getSelection "delete"

	# if the user has cancelled return to the main menu
	if $cancelled; then
		return
	fi

	deletion=$creation

	# if selection is successful, confirm deletion with user
	while true; do

		# make selection name more readable
		deleteName="${deletion//_/ }"


		printf "\n"
		read  -p "Are you sure you want to delete $deleteName [y/n]?: " yn
		case $yn in 
			[Yy] | [Yy][Ee][Ss] ) rm -rf Data/"$deletion";
			 					printf "\n 	$deleteName was successfully deleted. \n\n"; break;;
			[Nn] | [Nn][Oo] ) printf "\n 	$deleteName was not deleted. \n\n"; break;;
			* ) printf "\n 	Selection invalid, please try again.\n\n";;
		esac

	done


}
 
create() {
	printf " Enter (c) to cancel\n"
	#repeatedly asks the user for a valid name
	while true; do
		printf "\n"
		read  -p "Enter a name for your creation: " name

		# user cancelled
		if [ "$name" = "C" ] || [ "$name" = "c" ]; then
			printf "\n 	Create cancelled.\n\n";return;
		fi

		#replace spaces with underscores
		name="${name// /_}"
			
		# if name doesn't exist, create it
		if [ ! -d Data/$name ]; then
			mkdir -p Data/"$name"; break
		fi

		printf "\n	Creation already exists, please try another name.\n"
	done 


	# generate text video
	ffmpeg -loglevel quiet -f lavfi -i color=c=black:s=320x240:d=5 -vf \
	"drawtext=fontfile=/path/to/font.ttf:fontsize=28: \
 	fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:text='$name'" \
	Data/"$name"/"$name"_video.mp4


	# begin recording proces
	recording=true
	while $recording; do

		printf "\n"
		# ask user to press any key to begin recording audio
		read -n 1 -s -r -p "Press any key to begin recording (5 seconds) "

		# record audio for 5 seconds
		printf "\n\nRecording audio...\n"
		ffmpeg -loglevel quiet -f alsa -i default Data/"$name"/"$name"_audio.wav

		# ask user if they want to hear the audio
		while true; do

			printf "\n"
			read  -p "Do you wish to hear the recorded audio [y/n]?: " yn

			case $yn in 
				[Yy] | [Yy][Ee][Ss] ) printf "\n\nPlaying audio...";
				ffplay -loglevel quiet -autoexit -i Data/"$name"/"$name"_audio.wav; break;;

				[Nn] | [Nn][Oo] ) recording=false; break;;
				* ) printf "\n 	Selection invalid, please try again.\n\n";;
			esac
		done

		# ask user if they want to keep or redo the audio
		while true; do

			printf "\n"
			read -p "Do you want to (k)eep or (r)edo the audio? [k/r]?: " kr

			case $kr in
				[Kk] | [Kk][Ee][Ee][Pp] ) recording=false;break;;
				[Rr] | [Rr][Ee][Dd][Oo] ) recording=true;break;;
				* ) printf "\n 	Selection invalid, please try again.\n\n";;
			esac

		done

	done
	
	
	#combine audio and video
	ffmpeg -loglevel quiet -i Data/"$name"/"$name"_video.mp4 -i Data/"$name"/"$name"_audio.mp3 -filter_complex\
	amix=inputs=2 Data/"$name"/"$name"_merged.mkv

	#remove audio and video files
	rm -f Data/"$name"/"$name"_video.mp4 Data/"$name"/"$name"_audio.mp3

	# turn name into displayable format and print message to user
	displayName="${name//_/ }"

	printf "\n 	$displayName was successfully created\n\n"
}

# ask user for action, keep repeating until program is quit
while true; do

	# display main menu
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

	# ask user for selection
	read  -p "Enter a selection [l/p/d/c/q]: " selection

		case $selection in 
			[Ll] | [Ll][Ii][Ss][Tt] ) clear;list;;
			[Pp] | [Pp][Ll][Aa][Yy] ) clear;play;;
			[Dd] | [Dd][Ee][Ll][Ee][Tt][Ee] ) clear;delete;;
			[Cc] | [Cc][Rr][Ee][Aa][Tt][Ee] ) clear;create;;
			[Qq] | [Qq][Uu][Ii][Tt] ) printf "\n 	Thank you for using NameSayer!\n\n";exit 0;break;;
			* ) printf "\n 	Selection invalid, please try again.\n\n"; continue;
		esac

		read -n 1 -s -r -p "Press any key to return to main menu "
done


