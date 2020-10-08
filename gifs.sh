#!/bin/bash
#
# This script generates gif images from input video files
#

cd "$(dirname "$0")"
. "common.sh"

# defaults
scale=640
sample_rate=15
framerate=15
length_seconds=5
dither=bayer
cleanup=false
begin_time=0

usage() {
    echo "Usage: $(basename "$0") [-i inputDir] [-o outputDir] [-l length] [-b beginTime] [-s scale] [-f framerate] [-r sampleRate] [-d dither] [-v verbosity] [-c]"
    echo -e "\nOptions:"
    echo -e "\t-i inputDirectory"
    echo -e "\t\tDirectory containing video files to read"
    echo -e "\t\tDefault: $in"
    echo -e "\t-o outputDirectory"
    echo -e "\t\tDirectory to write gifs to"
    echo -e "\t\tDefault: $out"
    echo -e "\t-l length"
    echo -e "\t\tMax length in seconds for output gifs"
    echo -e "\t\tDefault: $length_seconds"
    echo -e "\t-b beginTime"
    echo -e "\t\tBegin at specified video time for gif creation"
    echo -e "\t\tDefault: $begin_time"
    echo -e "\t-s scale"
    echo -e "\t\tOutput image scale for gifs"
    echo -e "\t\tDefault: $scale"
    echo -e "\t-f framerate"
    echo -e "\t\tOutput image framerate for gifs"
    echo -e "\t\tDefault: $framerate"
    echo -e "\t-r sampleRate"
    echo -e "\t\tSample rate from source videos"
    echo -e "\t\tDefault: $sample_rate"
    echo -e "\t-d dither"
    echo -e "\t\tFfmpeg dither option"
    echo -e "\t\tDefault: $dither"
    echo -e "\t-v verbosity"
    echo -e "\t\tFfmpeg verbosity log level"
    echo -e "\t\tDefault: $log_level"
    echo -e "\t-c"
    echo -e "\t\tCleanup files after gif generation"
    exit 1
}

while getopts "i:o:l:s:f:r:v:b:c" opt; do
    case "$opt" in
        i) in=$OPTARG;;
        o) out=$OPTARG;;
        l) length_seconds=$OPTARG;;
	b) begin_time=$OPTARG;;
        s) scale=$OPTARG;;
        f) framerate=$OPTARG;;
        r) sample_rate=$OPTARG;;
        v) log_level=$OPTARG;;
	c) cleanup=true;;
        *) usage;;
    esac
done
OPTIND=1

# simple support for usage like 'this.sh help', or to prevent unintentional misuse with flags
if [[ ${#1} -gt 0 && $(printf -- "$1" | grep -c '^-') -le 0 ]]; then
    usage
fi

validate_directories

echo "Generating gifs..."
for file in "$in"/*; do
    echo -e "\t$file"
    total=$(ffprobe -i "$file" -v quiet \
        -show_entries format=duration -of csv="p=0" | sed 's/\.[^.]*$//')
    if [[ $(echo "$total" | grep -c '^[1-9][0-9]*$') -le 0 ]]; then
        ffprobe -i "$file" -v error > /dev/null
        echo -e "\t\tCould not read video, file will be skipped!"
        continue
    fi

    start=$begin_time
    while [[ "$start" -lt "$total" ]]; do
        echo -e "\t\t$start to $(($start + $length_seconds))"
        gif="${file##*/}"
        gif="$(printf "$out/${gif%.*}-%04d.gif" $start)"
        ffmpeg -i "$file" -v "$log_level" \
            -t "$length_seconds" -ss "$start" \
            -vf "fps=$framerate,scale=$scale:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse=dither=$dither" \
            -r "$sample_rate" -y "$gif"
        let start="$start"+"$length_seconds"
    done

    if [[ "$cleanup" = true ]]; then
        rm "$file"
    fi
done

echo "All gifs created"
