# About
This repo contains wrapper scripts for simplifying [ffmpeg](https://ffmpeg.org/) use for generation of thumbnails

# Gif Generation
`gifs.sh` creates a series of gif files from input videos

Gif generation has options for length, size, and quality. See script usage for details.

# Image Generation
`thumbs.sh` creates a series of image files from input videos

Image generation has options for frequency and format. See script usage for details.

# Usage
Executable scripts respond to `help` or `-h` (or any unsupported options) with providing usage instructions.

## Generating Images
1. Place video file(s) in the `input` directory (or reference your desired input directory using the `-i` option)
1. Invoke the script above for the type of image generation you would like to perform
1. Images will be generated in the `output` directory (or the specified directory with the `-o` option)
