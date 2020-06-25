#!/bin/bash

cd "$(dirname "$0")"

in='input'
out='output'

scale=320
sample_rate=30
framerate=15
length_seconds=5

if [[ ! -d "$in" ]]; then
    echo "Input directory '$in' not found!"
    exit 1
fi

if [[ ! -d "$out" ]]; then
    mkdir "$out"
fi

echo "Generating gifs..."
for file in "$in"/*; do
    echo -e "\t$file"
    total=$(ffprobe -i "$file" -v quiet \
        -show_entries format=duration -of csv="p=0" | sed 's/\.[^.]*$//')
    start=0
    while [[ "$start" -lt "$total" ]]; do
        gif="$(printf "$out/${file##*/}.%04d.gif" $start)"
        ffmpeg -i "$file" -v warning \
            -t "$length_seconds" -ss "$start" \
            -vf "fps=$framerate,scale=$scale:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse=dither=bayer" \
            -r "$sample_rate" -y "$gif"
        let start="$start"+"$length_seconds"
    done
done
