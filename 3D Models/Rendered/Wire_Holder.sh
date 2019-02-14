#!/bin/sh

montage 0001.png 0003.png 0005.png 0007.png -tile 4x1 -geometry 148x108+0+0 -background transparent wire-holder-straight.png
montage 0002.png 0004.png 0006.png 0008.png -tile 4x1 -geometry 148x108+0+0 -background transparent wire-holder-diagonal.png
montage 0009.png 0011.png 0013.png 0015.png -tile 4x1 -geometry 148x108+0+0 -background transparent wire-holder-straight-shadow.png
montage 0010.png 0012.png 0014.png 0016.png -tile 4x1 -geometry 148x108+0+0 -background transparent wire-holder-diagonal-shadow.png