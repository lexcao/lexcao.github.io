#!/bin/bash
find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) -exec sh -c 'if [ ! -f "${1%.*}.webp" ]; then cwebp "$1" -o "${1%.*}.webp"; fi' _ {} \;
