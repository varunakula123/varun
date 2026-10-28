#!/bin/bash
# spotlight + glass: sharp lit subject area, frosted/dimmed glass elsewhere, sheen + edge highlight
ffmpeg -v error -y -i in/src.mp4 -filter_complex "
[0:v]format=rgba,split=3[a][b][c];
[a]gblur=sigma=14,eq=brightness=-0.15:saturation=0.9,colorchannelmixer=rr=0.92:gg=0.96:bb=1.05[bg];
[b]eq=brightness=0.04:contrast=1.06[fg];
[c]format=gray,geq=lum='255*pow(clip(1-hypot((X-W*0.58)/(W*0.36),(Y-H*0.5)/(H*0.55)),0,1),0.7)',gblur=sigma=18[mask];
[fg][mask]alphamerge[fga];
[bg][fga]overlay=format=rgb[sp];
color=c=white:s=1024x576:r=30,format=rgba,geq=r=255:g=255:b=255:a='clip(70*exp(-pow((X+Y*0.6-W*0.2-T*160)/70,2)),0,255)'[shx];
[sp][shx]overlay=shortest=1:format=rgb,format=yuv420p,
drawbox=x=6:y=6:w=iw-12:h=ih-12:color=white@0.35:t=2,
drawbox=x=14:y=14:w=iw-28:h=ih-28:color=white@0.12:t=1[out]
" -map "[out]" -map 0:a? -c:v libx264 -crf 18 -c:a copy out.mp4
