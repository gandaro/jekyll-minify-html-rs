#!/bin/sh
# Copyright (C) 2026  Svend Gundestrup
# SPDX-License-Identifier: AGPL-3.0-or-later
# docs/assets demo capture — headless Chrome frames -> png + avif + webp.
# Build-host tools: Chrome (CHROME_BIN), ffmpeg (libsvtav1), img2webp.
set -eu
dir="docs/assets"
name="$(basename "$PWD" | tr "A-Z" "a-z")-demo"
chrome="${CHROME_BIN:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
[ -x "$chrome" ] || { echo "Chrome not found (set CHROME_BIN)" >&2; exit 1; }
command -v ffmpeg >/dev/null 2>&1 || { echo "ffmpeg not found" >&2; exit 1; }
command -v img2webp >/dev/null 2>&1 || { echo "img2webp not found" >&2; exit 1; }
mkdir -p "$dir/frames"
for i in 0 1 2 3; do
  if ! "$chrome" --headless=new --disable-gpu --hide-scrollbars \
    --screenshot="$dir/frames/f$i.png" --window-size=880,560 \
    "file://$PWD/$dir/demo.html?step=$i" >/dev/null 2>&1; then
    echo "Chrome screenshot failed at step $i" >&2
    exit 1
  fi
done
cp "$dir/frames/f0.png" "$dir/$name.png"
if ! ffmpeg -y -framerate 1 -i "$dir/frames/f%d.png" -c:v libsvtav1 -crf 35 \
  -pix_fmt yuv420p "$dir/$name.avif" >/dev/null 2>&1; then
  echo "ffmpeg AVIF encode failed (requires libsvtav1)" >&2
  exit 1
fi
if ! img2webp -loop 0 -d 1000 "$dir"/frames/f*.png -o "$dir/$name.webp" >/dev/null 2>&1; then
  echo "img2webp encode failed" >&2
  exit 1
fi
echo "wrote $dir/$name.{png,avif,webp}"
