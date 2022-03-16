https://gitlab.fhnw.ch/hgk-ml/hgk-ml-tools/-/tree/master/ffmpeg_cheatsheet
## Overlay merging PNG
```
ffmpeg -i B.png -i A.png -filter_complex "[1]scale=iw/2:-1[b];[0:v][b] overlay" out.png

ffmpeg -i ./L1/%d.png -i ./L2/%d.png -i ./L3/%d.png -i ./L4/%d.png -filter_complex "[0][1]overlay[bg0];[bg0][2]overlay[bg1];[bg1][3]overlay[v]" -map "[v]"  ./output/sequence/frame%d.png
```
