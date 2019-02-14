#!/bin/sh

convert 000[1-9].png 001[0-9].png 002[0-9].png 003[0-9].png 0040.png -transpose miff:- |\
	montage - -geometry 136x136+0+0 -tile 8x5 -background transparent miff:- | \
	convert - -transpose chain-pole-base.png