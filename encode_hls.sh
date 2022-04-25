#!/bin/bash

ffmpeg -y -err_detect explode -xerror -i $1 \
-filter_complex "[0:v] split=3[fileout0][fileout1][fileout2]; [fileout0]setdar=w*sar/h,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='1920x1080-30fps':fontsize=36:fontcolor=white[fileout0]; [fileout1]setdar=w*sar/h,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='1280x720-30fps':fontsize=36:fontcolor=white[fileout1];[fileout2]setdar=w*sar/h,drawtext=fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf:text='854x480-30fps':fontsize=36:fontcolor=white[fileout2]" \
-map [fileout0] -c:v:0 libx264 -pix_fmt:v:0 yuv420p -tune film -profile:v main -s:v:0 1920x1080 -bf 3 -refs 4 -avoid_negative_ts 1 -shortest -vsync 1 -x264-params "nal-hrd=cbr:force-cfr=1" -b:v:0 3M -maxrate:v:0 3M -minrate:v:0 3M -bufsize:v:0 6M -preset fast -g 48 -sc_threshold 0 -keyint_min 48 \
-map [fileout1] -c:v:1 libx264 -pix_fmt:v:1 yuv420p -tune film -profile:v main -s:v:1 1280x720 -bf 3 -refs 4 -avoid_negative_ts 1 -shortest -vsync 1 -x264-params "nal-hrd=cbr:force-cfr=1" -b:v:1 2200k -maxrate:v:1 2200k -minrate:v:1 2200k -bufsize:v:1 4400k -preset fast -g 48 -sc_threshold 0 -keyint_min 48 \
-map [fileout2] -c:v:2 libx264 -pix_fmt:v:2 yuv420p -tune film -profile:v main -s:v:2 854x480 -bf 3 -refs 4 -avoid_negative_ts 1 -shortest -vsync 1 -x264-params "nal-hrd=cbr:force-cfr=1" -b:v:2 1400k -maxrate:v:2 1400k -minrate:v:2 1400k -bufsize:v:2 2800k -preset fast -g 48 -sc_threshold 0 -keyint_min 48 \
-map a:0 -c:a:0 aac -b:a:0 96k -ac 2 \
-map a:0 -c:a:1 aac -b:a:1 96k -ac 2 \
-map a:0 -c:a:2 aac -b:a:2 48k -ac 2 \
-f hls \
-hls_time 2 \
-hls_playlist_type vod \
-hls_flags independent_segments \
-hls_segment_type mpegts \
-hls_segment_filename stream_%v/data%02d.ts \
-master_pl_name master.m3u8 \
-var_stream_map "v:0,a:0 v:1,a:1 v:2,a:2" stream_%v/stream.m3u8

