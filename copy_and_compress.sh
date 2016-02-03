#!/bin/sh
# INPUT: list of id (one id on line)
# OUTPUT: directories with compressed images
# id -> directory_name
# types 1, 4, 8, 9 

while IFS='' read -r line || [[ -n $line ]]; do
	# create dir with image id
	echo "Creating new dir $line"
	mkdir -p "$line"
	for i in 1 4 8 9
	do
		url="http://dp.mycdn.me/getImage?photoId=$line&type=$i"
		target="$line/raw_$i"
		wget -q -O $target $url     	
		pngquant -f -s3 -o "$line/image_$i" $target
		echo "Image $line type $i loaded and compressed"
	done

done < "$1"
