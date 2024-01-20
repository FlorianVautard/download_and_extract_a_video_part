#!/bin/bash

proxy_server_ip=""
proxy_server_port=""
tmp_directory="/tmp"

# Function to print usage information
usage() {
    echo "Usage: $0 [-a Audio only] [-u <video_url>] [-s <start_time>] [-t <duration>] [-o <output_file>] [-p Use proxy for downloading] [-ps <proxy_server_ip>] [-pp <proxy_server_port>]"
    exit 1
}

###############################################################################################
# CHECK DEPENDENCIES

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

###############################################################################################
# PARSE COMMAND LINE OPTIONS

while getopts ":u:s:t:o:p:ps:pp:" opt; do
    case $opt in
        a)
            audio=true
            ;;
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
        p)
            use_proxy=true
            ;;
        ps)
            proxy_server_ip=$OPTARG
            ;;
        pp)
            proxy_server_port=$OPTARG
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

###############################################################################################
# PROXY PART

# Ask if a proxy should be used, if not provided as a parameter
if [[ -z "$use_proxy" ]]; then
    read -p "Do you want to use a proxy for downloading? (YES/NO): " use_proxy_input
    case $use_proxy_input in
        [Yy][Ee][Ss])
            use_proxy=true
	    echo "A proxy will be used."
            ;;
        *)
            use_proxy=false
	    echo "A proxy will not be used."
            ;;
    esac
fi

# Check if a proxy should be used
if [[ "$use_proxy" == true ]]; then
    if [[ -z "$proxy_server_ip" ]] || [[ -z "$proxy_server_port" ]]; then
        # Ask for the proxy server details
        read -p "Enter the proxy server address: " proxy_server_ip
        read -p "Enter the proxy server port: " proxy_server_port
    fi

    # Establish the SSH connection for SOCKS proxy
    ssh -D "$proxy_server_port" -q -C -N -f "$proxy_server_ip"
    proxy_command="--proxy socks5://127.0.0.1:$proxy_server_port"
fi

###############################################################################################
# DOWNLOAD AND EXTRACT VIDEO

# Ask for the URL of the video to be kept if not provided as a parameter
while [[ -z "$video_url" ]]; do
    read -p "Please enter the video URL: " video_url
done

# Ask if it is only the audio which will be downloaded
if [[ -z "$audio" ]]; then
	read -p "Do you want to download only the audio of the video? (true/false)" audio
fi

# If $audio is still empty, download all the video
if [[ -z "$audio" ]]; then
    video_format="-f bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4"
    echo "The video with the audio will be downloaded."	
else
    video_format="-f bestaudio[ext=m4a]"
    echo "The audio of the video will be downloaded."
fi


# Get the title of the video using yt-dlp
video_title=$(yt-dlp $proxy_command --get-title "$video_url")

# Ask for the name of the extracted file or use the video title if not provided as a parameter
if [[ -z "$output" ]]; then
    read -p "What is the name of the video (current title is '$video_title')? " output
fi

# If output is still empty, use the video title
if [[ -z "$output" ]]; then
    output="$video_title"
    echo "The name of the video will be: $video_title"
fi

# Ask for the start time of the portion to keep if not provided as a parameter
read -p "At what time does the portion to keep start (in the format HH:MM:SS)? " start_time

# Check if start_time is empty, if yes, download the entire video, if no, ask for duration and download a part of the video
if [[ -z "$start_time" ]]; then
    echo "The entire video will be downloaded."
    # Download the video with yt-dlp and save it in /tmp
    yt-dlp $proxy_command "$video_format" "$video_url" --output "$output.mp4"

    echo "The entire video has been successfully downloaded. The output file is $output.mp4."
else
    # If start_time is provided, ask for the duration
    while [[ -z "$duration" ]]; do
        read -p "How long does the video to keep last (in the format HH:MM:SS)? " duration
    done
    
    # Download the video with yt-dlp and save it in /tmp
    yt-dlp $proxy_command "$video_format" "$video_url" --output "$tmp_directory/video.mp4"

    # Use ffmpeg to cut the video
    ffmpeg -ss "$start_time" -t "$duration" -i "$tmp_directory/video.mp4" "$tmp_directory/$output.mp4"

    # Move the cut video to the current directory
    mv "$tmp_directory/$output.mp4" .
    
    # Remove the temporary video file
    rm "$tmp_directory/video.mp4"
    
    echo "The video has been successfully cut. The output file is '$output.mp4'."
fi
