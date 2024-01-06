#!/bin/bash

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

# Ask for the URL of the video to be kept
while [[ -z "$video_url" ]]; do
    read -p "Please enter the video URL: " video_url
done

# Ask for the start time of the portion to keep
while [[ -z "$start_time" ]]; do
    read -p "At what time does the portion to keep start (in the format HH:MM:SS)? " start_time
done

# Ask for the duration of the video to keep
while [[ -z "$duration" ]]; do
    read -p "How long does the video to keep last (in the format HH:MM:SS)? " duration
done

# Ask for the name of the extracted file
while [[ -z "$output" ]]; do
    read -p "What is the name of the extracted file? " output
done

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