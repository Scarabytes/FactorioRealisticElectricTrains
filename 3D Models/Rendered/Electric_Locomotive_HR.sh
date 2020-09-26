#!/bin/sh

# Full image
echo "Stitching main images"

convert 000[1-9].png 001[0-6].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-1.png

convert 001[7-9].png 002[0-9].png 003[0-2].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-2.png

convert 003[3-9].png 004[0-8].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-3.png

convert 0049.png 005[0-9].png 006[0-4].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-4.png

convert 006[5-9].png 007[0-9].png 0080.png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-5.png

convert 008[1-9].png 009[0-6].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-6.png

convert 009[7-9].png 010[0-9].png 011[0-2].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-7.png

convert 011[3-9].png 012[0-8].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-8.png

convert 0129.png 013[0-9].png 014[0-4].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-9.png

convert 014[5-9].png 015[0-9].png 0160.png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-10.png

convert 016[1-9].png 017[0-6].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-11.png

convert 017[7-9].png 018[0-9].png 019[0-2].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-12.png

convert 019[3-9].png 020[0-8].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-13.png

convert 0209.png 021[0-9].png 022[0-4].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-14.png

convert 022[5-9].png 023[0-9].png 0240.png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-15.png

convert 024[1-9].png 025[0-6].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-hr-16.png

# Mask
echo "Stitching masks"

convert 025[7-9].png 026[0-9].png 027[0-2].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-1.png

convert 027[3-9].png 028[0-8].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-2.png

convert 0289.png 029[0-9].png 030[0-4].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-3.png

convert 030[5-9].png 031[0-9].png 0320.png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-4.png

convert 032[1-9].png 033[0-6].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-5.png

convert 033[7-9].png 034[0-9].png 035[0-2].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-6.png

convert 035[3-9].png 036[0-8].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-7.png

convert 0369.png 037[0-9].png 038[0-4].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-8.png

convert 038[5-9].png 039[0-9].png 0400.png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-9.png

convert 040[1-9].png 041[0-6].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-10.png

convert 041[7-9].png 042[0-9].png 043[0-2].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-11.png

convert 043[3-9].png 044[0-8].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-12.png

convert 0449.png 045[0-9].png 046[0-4].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-13.png

convert 046[5-9].png 047[0-9].png 0480.png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-14.png

convert 048[1-9].png 049[0-6].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-15.png

convert 049[7-9].png 050[0-9].png 051[0-2].png miff:- |\
	montage - -geometry 476x460+0+0 -tile 4x4 -background transparent miff:- | \
	convert - electric-locomotive-mask-hr-16.png
