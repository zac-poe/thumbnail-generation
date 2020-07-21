#!/bin/bash
#
# This script generates image files for frames from input video files
#

cd "$(dirname "$0")"
. "common.sh"

# defaults
framerate=1
format='png'
cleanup=false

usage() {
    echo "Usage: $(basename "$0") [-i inputDir] [-o outputDir] [-r framerate] [-f format] [-v verbosity] [-c]"
    echo -e "\nOptions:"
    echo -e "\t-i inputDirectory"
    echo -e "\t\tDirectory containing video files to read"
    echo -e "\t\tDefault: $in"
    echo -e "\t-o outputDirectory"
    echo -e "\t\tDirectory to write gifs to"
    echo -e "\t\tDefault: $out"
    echo -e "\t-r framerate"
    echo -e "\t\tFramerate frequency to generate images (seconds ratio)"
    echo -e "\t\tDefault: $framerate"
    echo -e "\t-f format"
    echo -e "\t\tOutput image format"
    echo -e "\t\tDefault: $format"
    echo -e "\t-v verbosity"
    echo -e "\t\tFfmpeg verbosity log level"
    echo -e "\t\tDefault: $log_level"
    echo -e "\t-c"
    echo -e "\t\tCleanup input files after image generation"
    echo -e "\t\tDefault: disabled"
    exit 1
}

while getopts "i:o:r:f:v:c" opt; do
    case "$opt" in
        i) in=$OPTARG;;
        o) out=$OPTARG;;
        r) framerate=$OPTARG;;
        f) format=$OPTARG;;
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

echo "Generating thumbnails..."
for file in "$in"/*; do
    echo -e "\t$file"
    image=${file##*/}
    ffmpeg -i "$file" -v "$log_level" \
        -vf fps="$framerate" \
        -y "$out/${image%.*}-%04d.$format"

    if [[ "$cleanup" = true ]]; then
        rm "$file"
    fi
done

echo "All thumbnails created"
