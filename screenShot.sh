#!/bin/bash

# varibles ---------------------------
NET=networks/GoogleNet-ILSVRC12-subset #path to model

X=170 #X cooridnate for crop location in pixels
Y=390 #y cooridnate for crop location in pixels
WIDTH=1280 #num of pixels in the X axis
HEIGHT=554 #num of pixels in the y axis
crop=$WIDTH'x'$HEIGHT'+'$X'+'$Y #used in the convert funtion to crop the screenshot

exposure[1]=1000
exposure[2]=900
exposure[3]=1100

iter=1 #every captured screenshot adds one. Iter is reset to 1 when directory is changed
#-------------------------------------
# functions---------------------------
open (){
	gnome-terminal --working-directory 'jetson-inference/build/aarch64/bin' -e './imagenet-camera alexnet --prototxt=$NET/deploy.prototxt --model='$NET'/snapshot_iter_1800.caffemodel --mean_binary='$NET'/mean.binaryproto --labels='$NET'/labels.txt --input_blob=data --output_blob=softmax'
}

#checkAndInstall (){ 
#gnome-terminal -e  "dpkg -s scrot"
# gnome-terminal -e  "dpkg -s imagemagick"
#gnome-terminal -e  "dpkg -s v4l-utils"
#if [$installSCROT = 1]; then
# gnome-terminal -e  "sudo apt-get install scrot"
 # fi
 # if [$installMAGICK = 1]; then
 #   gnome-terminal -e  "sudo apt-get install imagemagick"
 # fi
 # if [$installUTIL = 1]; then
 #   gnome-terminal -e  "sudo apt-get install v4l-utils"
 # fi
#}

image () {
	for i in 1 2 3
	do
		gnome-terminal -e  "v4l2-ctl -d /dev/video0 -c exposure_absolute="$exposure[$i]
		sleep .5 # allows time for exposure to update on screen
		scrot $uncroppedFileName'-'$iter'.png' -e 'mv $f ~/'$uncropped;
		convert $uncropped$uncroppedFileName'-'$iter'.png' -crop $crop $directory$fileName'-'$iter'.png'
		(( iter++ ))
		echo Captured
	done
} 

creator (){
	if [ ! -d /home/nvidia/$location/$fileName ] 
	then
		mkdir -p /home/nvidia/$location/$fileName
	fi
	if [ ! -d /home/nvidia/$location/$uncroppedFileName ] 
	then
		mkdir -p /home/nvidia/$location/$uncroppedFileName
	fi 
}

# txtcreator (){
#}
#echo is this for ImageNet (1) or detectNet(2)
#read modelType

directoryQuestion (){
	echo Enter directory
	read location

	echo Enter file name
	read fileName
	
	directory=$location'/'$fileName'/'
	uncroppedFileName=$fileName'Uncropped'
	uncropped=$location'/'$uncroppedFileName'/'
}
#-------------------------------------

#checkAndInstall

directoryQuestion

open

printf "\n"
echo Press c to capture Screenshot
echo Press a to append new folder
echo Press m to modify camera 
echo Press e to email directory
echo Press r to  
echo Press a to 
printf "\n"

creator

#camera setup
gnome-terminal -e  "v4l2-ctl -d /dev/video0 -c exposure_auto=1" 
gnome-terminal -e  "v4l2-ctl -d /dev/video0 -c focus_auto=0 " 
gnome-terminal -e  "v4l2-ctl -d /dev/video0 -c focus_absolute=88" 

while [ "$fileName" != "" ]; 
do 
read -s -n 1 key <&1
	if [[ $key = c ]]; then
	
		image
		printf "\n"
		
	fi 
	if [[ $key = a ]] ; then
	
	directoryQuestion
	creator
	iter=1
	echo File Changed to: $directory
	
	fi
	if [[ $key = m ]] ; then
	
		printf "\n"
		
		echo To change from auto to manual exposure 
		echo   v4l2-ctl -d /dev/video0 -c exposure_auto=1
		echo To change from manual to auto exposure 
		echo   v4l2-ctl -d /dev/video0 -c exposure_auto=0
		echo To change the value in manual exposure 
		echo   v4l2-ctl -d /dev/video0 -c exposure_absolute=
		echo To change from auto to manual focus 
		echo   v4l2-ctl -d /dev/video0 -c focus_auto=0
		echo To change from manual to auto focus 
		echo   v4l2-ctl -d /dev/video0 -c focus_auto=1
		echo To change the value in manual focus 
		echo   v4l2-ctl -d /dev/video0 -c focus_absolute=
		echo To change the brightness value 
		echo   v4l2-ctl -d /dev/video0 -c brightness=
			
		echo Enter Camera command 
		read cameraCommand
		
		gnome-terminal -e "$cameraCommand"
		
	fi
done
