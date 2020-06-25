#!/bin/bash

cd "$(dirname "$0")"

# common defaults
in='input'
out='output'
log_level='warning'

fail() {
    echo -e "$1"
    exit 1
}

verify() {
    which "$1" > /dev/null || fail "Requires $1 to be installed"    
}

# verify system requirements
verify 'ffmpeg'
verify 'ffprobe'

validate_directories() {
    if [[ ! -d "$in" ]]; then
        fail "Input directory '$in' not found!"
    fi

    if [[ ! -d "$out" ]]; then
        mkdir -p "$out" || fail "Failed to create output directory '$out'"
    fi
}
