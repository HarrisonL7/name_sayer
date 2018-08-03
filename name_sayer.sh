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

select() {
	while true; do
		read  -p "Enter the name of the creation you wish to $1: " selection

		# replace spaces with underscores
		selection="${$1// /_}"

		# check if selection exists
		if [ -d Data/$selection ]; then
				break
		fi

		printf "\n 	That creation does not exist, please try again.\n\n"
	done
}

list() {


	# check if there are no creations
	if [ -z "$(ls -A Data)" ]; then

		#if so, notify the user
		printf "\nNo creations exist\n\n"
		
	else 

		# otherwise loop through folder and list contents
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

	select ".."
	# get user to select a creation to play

	ffplay -autoexit -i Data/"$selection"/"$selection"_merged.mkv

}

delete() {
	# list all creations
	list

	# get user to select a creation to delete
	select "delete"

	# create displayable format of name to the user
	deletion="${selection//_/ }"


	# confirm deletion with user
	while true; do
		read  -p "Are you sure you want to delete $deletion [y/n]? :" yn

		case $yn in 
			[Yy] | [Yy][Ee][Ss] ) rm -rf Data/"$selection";
			 					printf "\n 	$deletion was successfully deleted. \n\n"; break;;
			[Nn] | [Nn][Oo] ) printf "\n 	$deletion was not deleted. \n\n"; break;;
			* ) printf "\n 	Selection invalid, please try again.\n\n";;
		esac

	done
}
 
create() {

	#repeatedly asks the user for a valid name
	while true; do
		read  -p "Enter a name for your creation: " name

		#replace spaces with underscores
		name="${name// /_}"
			
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
	Data/"$name"/"$name"_video.mp4


	# begin recording proces
	recording=true
	while $recording; do

		# ask user to press any key to begin recording audio
		read -n 1 -s -r -p "Press any key to continue"

		# record audio for 5 seconds
		printf "\nrecording audio...\n"
		ffmpeg -f alsa -i default Data/"$name"/"$name"_audio.wav

		# ask user if they want to hear the audio
		while true; do
			read  -p "Do you wish to hear the recorded audio [y/n]? :" yn

			case $yn in 
				[Yy] | [Yy][Ee][Ss] ) printf "playing\n";
				ffplay -autoexit -i Data/"$name"/"$name"_audio.wav; break;;

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

#ask user for action, keep repeating until program is quit
while true; do
	read  -p "Enter a selection [l/p/d/c/q]: " selection

		case $selection in 
			[Ll] | [Ll][Ii][Ss][Tt] ) list;;
			[Pp] | [Pp][Ll][Aa][Yy] ) play;;
			[Dd] | [Dd][Ee][Ll][Ee][Tt][Ee] ) delete;;
			[Cc] | [Cc][Rr][Ee][Aa][Tt][Ee] ) create;;
			[Qq] | [Qq][Uu][Ii][Tt] ) printf "Thank you for using NameSayer!\n\n";exit 0;break;;
			* ) printf "\n 	Selection invalid, please try again.\n\n";;
		esac
done


