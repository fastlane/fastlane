### These files are for rspec purpose only. They are not suitable for uploading to App Store Connect.

Use the following command to generate new video files:
```shell
ffmpeg -loglevel error \
     -f lavfi -i "color=c=black:s=1242x2208:r=30" \  # input comes from libavfilter, not a file, then use "color" source filter to generate video frames
     -f lavfi -i anullsrc=channel_layout=mono:sample_rate=44100 \  # input comes from libavfilter again and generate silent audio
     -t 15 -c:v libx264 \  # duration; video encoding
     -pix_fmt yuv420p \  # sets pixel format to most common on all devices
     -profile:v baseline \  # baseline h.264 profile (most common on all devices)
     -level 3.0  \  # h.264 level constraint (3.0 for old devices compat)
     -preset ultrafast \  # fastest encode
     -crf 51 \  # highest constant rate factor for maximum compression
     -c:a aac -b:a 8k \  # AAC audio codec; very low bitrate
     -movflags +faststart \  # put the 'moov' atom at the start of the file
     video.mp4  # output file name
```

_Note: remove all whitespaces and comments first_


