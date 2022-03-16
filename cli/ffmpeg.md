
## Overlay merging PNG
```
ffmpeg -i B.png -i A.png -filter_complex "[1]scale=iw/2:-1[b];[0:v][b] overlay" out.png
```
