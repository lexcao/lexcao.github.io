#!/bin/bash

# Define the root directory for the search (current directory of the script)
SEARCH_DIR="."

# Find all video files (mp4, mov, mkv, avi) in the current directory and subdirectories
# Using -print0 and read -r -d '''' to handle filenames with spaces or special characters
find "$SEARCH_DIR" -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.mkv" -o -iname "*.avi" \) -print0 | while IFS= read -r -d $'\0' video_file; do
    # Get the directory path of the video file
    dir_name=$(dirname "$video_file")
    # Get the base name of the video file (e.g., myvideo.mp4)
    base_name=$(basename "$video_file")
    # Get the filename without the extension (e.g., myvideo)
    file_name_no_ext="${base_name%.*}"
    
    # Define the output WebM file path
    webm_file="$dir_name/$file_name_no_ext.webm"

    # Check if the WebM file already exists
    if [ -f "$webm_file" ]; then
        echo "Skipping: '$video_file' - WebM version '$webm_file' already exists."
    else
        echo "Converting: '$video_file' to '$webm_file'..."
        # Convert the video to WebM using ffmpeg
        # Options:
        # -i "$video_file": Input file
        # -c:v libvpx-vp9: Use VP9 codec for video
        # -crf 30: Constant Rate Factor (quality, 0-63, lower is better, Sane range: 15-35)
        # -b:v 0: Target video bitrate (0 for CRF mode with VP9)
        # -c:a libopus: Use Opus codec for audio
        # -b:a 128k: Target audio bitrate
        # -hide_banner: Suppress ffmpeg's version and build information
        # -loglevel error: Show only errors
        ffmpeg -nostdin -i "$video_file" -c:v libvpx-vp9 -crf 30 -b:v 0 -c:a libopus -b:a 128k "$webm_file" -hide_banner -loglevel error
        
        if [ $? -eq 0 ]; then
            echo "Successfully converted: '$video_file' to '$webm_file'."
        else
            echo "Error converting '$video_file'. Check ffmpeg output."
            # Optionally, remove partially created webm file on error
            # rm -f "$webm_file"
        fi
    fi
done

echo "WebM conversion process finished."
