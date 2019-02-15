#!/bin/sh

montage 0001.png 0003.png 0005.png 0007.png -geometry 48x48+0+0 -tile 4x1 -background transparent pole-base-straight.png
montage 0002.png 0004.png 0006.png 0008.png -geometry 48x48+0+0 -tile 4x1 -background transparent pole-base-diagonal.png