#!/bin/bash
# Renders an animated chart HTML (one with a render(t) timeline and ?t= support) to MP4.
# Usage: ./render_mp4.sh   (edit the two render lines at the bottom: name, duration, hold)
# One headless-Chrome screenshot per frame at 30 fps, then ffmpeg. About 1 s per frame.
set -e
R="$(cd "$(dirname "$0")" && pwd)"
CH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
FPS=30
render() { # name duration hold
  f=$1; dur=$2; hold=$3; out="${TMPDIR:-/tmp}/frames_$f"; rm -rf "$out"; mkdir -p "$out"
  total=$(python3 -c "print(int(($dur+$hold)*$FPS))")
  for ((i=0;i<total;i++)); do
    t=$(python3 -c "print(min($i/$FPS, $dur))")
    "$CH" --headless=new --disable-gpu --hide-scrollbars --window-size=1920,1080 --screenshot="$out/$(printf %04d $i).png" "file://$R/$f.html?t=$t" >/dev/null 2>&1
  done
  ffmpeg -y -loglevel error -framerate $FPS -i "$out/%04d.png" -c:v libx264 -pix_fmt yuv420p -crf 18 -movflags +faststart "$R/$f.mp4"
  echo "$f: $total frames -> $(ls -la "$R/$f.mp4" | awk '{print $5}') bytes"
}
render 0.01_ae_top_skills 3.6 1.5
render 0.01_ae_dbt_share_trend 5.0 1.5
echo DONE
