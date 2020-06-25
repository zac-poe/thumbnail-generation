#!/bin/bash

cd "$(dirname "$0")"

in='input'
out='output'

framerate=1

if [[ ! -d "$in" ]]; then
    echo "Input directory '$in' not found!"
    exit 1
fi

if [[ ! -d "$out" ]]; then
    mkdir "$out"
fi

echo -e "Generating thumbs..."
ls "$in" | xargs -I {} ffmpeg -i "$in/{}" -v warning \
    -vf fps="$framerate" \
    -y "$out/{}.%04d.png"
