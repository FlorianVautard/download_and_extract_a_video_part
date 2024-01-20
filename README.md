# download_and_extract_a_video_part
A Bash program to download and extract a part of a video or audio. It is mainly a wrapper of [ytb-dl](https://github.com/yt-dlp/yt-dlp) and [ffmpeg](https://ffmpeg.org/download.html) in order to make it more user friendly. 
## Dependencies
To run, the program needs ffmpeg and yt-dlp.
## Installation
### FFMPEG
[https://ffmpeg.org/download.html](https://ffmpeg.org/download.html)
### Youtube-dl - now yt-dlp
[https://github.com/yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp)
## Configuration
You can set a proxy_server_ip, a proxy_server_port and a tmp directory at the begining of the file.
proxy_server_ip: <ip>
proxy_server_port : <port>
## Running
This program allows you to define the required parameter by sending the parameters directly to the program or in answering questions. You can also combine both , the parameter will be given directly and the question will not be asked.

An example below with the extraction of the entrance of the eyes of the tiger clip video.
```bash
# Without any parameters
> ./download_and_extract_a_video_part.sh  
Please enter the video URL: https://www.youtube.com/watch?v=btPJPFnesV4
Do you want to download only the audio of the video? (true/false)
> true
The audio will be downloaded
At what time does the portion to keep start (in the format HH:MM:SS)? 
> 00:00:00
How long does the video to keep last (in the format HH:MM:SS)? 
> 00:01:05
What is the name of the extracted file? intro_eyes_of_the_tiger
> ls
intro_eyes_of_the_tiger.mp4

# With only parameters
> ./download_and_extract_a_video_part.sh-u https://www.youtube.com/watch?v=btPJPFnesV4 -s 00:00:00 -t 00:01:05 -o intro_eyes_of_the_tiger
> ls
intro_eyes_of_the_tiger.mp4

# With both, parameters and answers
> ./download_and_extract_a_video_part.sh-u https://www.youtube.com/watch?v=btPJPFnesV4 -o intro_eyes_of_the_tiger
At what time does the portion to keep start (in the format HH:MM:SS)? 
> 00:00:00
How long does the video to keep last (in the format HH:MM:SS)? 
> 00:01:05
> ls
intro_eyes_of_the_tiger.mp4
```
