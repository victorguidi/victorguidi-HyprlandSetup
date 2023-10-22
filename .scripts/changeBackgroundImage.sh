#!/bin/bash

folder="$HOME/.bgimages/"

images=$(ls "$folder")

echo "$images"

if [[ -n "$@" ]]; then
	swww img "$folder/$@" --transition-fps 60
	exit 0
else
	echo "No image selected."
fi
