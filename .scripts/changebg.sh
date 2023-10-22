#!/bin/bash

folder="/home/kun/.bgimages/"

file=$(ls $folder | shuf -n1)
swww img $folder/$file --transition-fps 60

#restart the waybar
pkill waybar
waybar &
