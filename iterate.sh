#!/usr/bin/env bash

# Results:
# GIF source = 73Mb
# 
# 1) default(sierra) = 62sec (77Mb=68+8,8)
# 2) bayer 2 = 32sec (75Mb=66+8,8)
# 3) bayer 0 = 34sec (80Mb=71+8,8)
# 4) none = 30sec (62Mb=53+8,8)



ffmpeg_bin="/Users/dmirty/Downloads/ffmpeg"
palette="/tmp/palette.png"
filters="fps=10"
out_folder="out/"

gif_to_mp4() {
    $ffmpeg_bin -v error  -i $1  -r 25 -an -preset veryfast -c:v libx264 -crf 25 -maxrate 784K -profile:v baseline -pix_fmt yuv420p -threads 0 -movflags +faststart -y $2
}

# $1 - mp4 input
# $2 - dithering
# $3 - gif output
mp4_to_gif() {
    $ffmpeg_bin -v error -i $1 -vf "$filters,palettegen" -y $palette
    $ffmpeg_bin -v error -i $1 -i $palette -lavfi "$filters [x]; [x][1:v] $2" -y $3
}

start=`gdate +%s`
for f in *.gif; do
    if test -f "$f"
    then
        echo "$f"
        gif_to_mp4 $f $out_folder$f".mp4"
        
        # bayer dithering
        #mp4_to_gif $out_folder$f".mp4" "paletteuse=dither=bayer:bayer_scale=3" $out_folder$f"_mp4.gif"
        
        # no dithering
        mp4_to_gif $out_folder$f".mp4" "paletteuse=dither=none" $out_folder$f"_mp4.gif"
        
        # default = sierra error diffusion
        #mp4_to_gif $out_folder$f".mp4" "paletteuse" $out_folder$f"_mp4.gif"
    fi
done
end=`gdate +%s`

elapsed=$((end-start))
echo "Elapsed: $elapsed sec"






