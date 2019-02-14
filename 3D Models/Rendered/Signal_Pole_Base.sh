#!/bin/sh

convert 000[1-9].png 001[0-9].png 002[0-4].png  -transpose miff:- |\
	montage - -geometry 48x48+0+0 -tile 8x3 -background transparent miff:- | \
	convert - -transpose signal-pole-base.png