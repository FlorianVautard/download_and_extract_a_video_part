# download_and_extract_a_video_part
A Bash program to download and extract a part of a video. 
## Dependencies
To run, the program needs ffmpeg and yt-dlp.
## Installation
### FFMPEG
[https://ffmpeg.org/download.html](https://ffmpeg.org/download.html)
### Youtube-dl - now yt-dlp
[https://github.com/yt-dlp/yt-dlp](https://github.com/yt-dlp/yt-dlp)
## Running
An example below with the extraction of the entrance of the eyes of the tiger clip video.
```bash
> ./download_and_extract_a_video_part.sh
Please enter the video URL: https://www.youtube.com/watch?v=btPJPFnesV4
At what time does the portion to keep start (in the format HH:MM:SS)? 00:00:00
How long does the video to keep last (in the format HH:MM:SS)? 00:01:05
What is the name of the extracted file? intro_eyes_of_the_tiger

> ls
intro_eyes_of_the_tiger.mp4

```
