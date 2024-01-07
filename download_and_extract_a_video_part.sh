#!/bin/bash

# Function to print usage information
usage() {
    echo "Usage: $0 [-u <video_url>] [-s <start_time>] [-t <duration>] [-o <output_file>]"
    exit 1
}

# Parse command line options
while getopts ":u:s:t:o:" opt; do
    case $opt in
        u)
            video_url=$OPTARG
            ;;
        s)
            start_time=$OPTARG
            ;;
        t)
            duration=$OPTARG
            ;;
        o)
            output=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            usage
            ;;
    esac
done

# Check for the presence of yt-dlp
if ! command -v yt-dlp &> /dev/null; then
    echo "Error: yt-dlp is not installed. Please install it with 'pip install yt-dlp'."
    exit 1
fi

# Check for the presence of ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed. Please install it before continuing."
    exit 1
fi

# Ask for the URL of the video to be kept if not provided as a parameter
while [[ -z "$video_url" ]]; do
    read -p "Please enter the video URL: " video_url
done
# Get the title of the video using yt-dlp
video_title=$(yt-dlp --get-title "$video_url")

# Ask for the name of the extracted file if not provided as a parameter
while [[ -z "$output" ]]; do
    read -p "What is the name of the video (current title is '$video_title')? " output
done

# Ask for the start time of the portion to keep if not provided as a parameter
read -p "At what time does the portion to keep start (in the format HH:MM:SS)? " start_time

# Check if start_time is empty, if yes, download the entire video
if [[ -z "$start_time" ]]; then
    # Set the backup path to /tmp
    tmp_directory="/tmp"

    # Download the video with yt-dlp and save it in /tmp
    yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4' "$video_url" --output "$output.mp4"

    echo "The entire video has been successfully downloaded. The output file is $output.mp4."
    exit 0
else
	# If start_time is provided, ask for the duration
	while [[ -z "$duration" ]]; do
	    read -p "How long does the video to keep last (in the format HH:MM:SS)? " duration
	done
fi

# Set the backup path to /tmp
tmp_directory="/tmp"

# Download the video with yt-dlp and save it in /tmp
yt-dlp -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4' "$video_url" --output "$tmp_directory/video.mp4"

# Use ffmpeg to cut the video
ffmpeg -ss "$start_time" -t "$duration" -i "$tmp_directory/video.mp4" "$tmp_directory/$output.mp4"

# Move the cut video to the current directory
mv "$tmp_directory/$output.mp4" .

# Remove the temporary video file
rm "$tmp_directory/video.mp4"

echo "The video has been successfully cut. The output file is '$output.mp4'."
