convert 000[1-9].png 001[0-9].png 002[0-9].png 003[0-2].png miff:- |\
	montage - -geometry 253x212+0+0 -tile 4x8 -background transparent miff:- | \
	convert - electric-locomotive-shadow-1.png

convert 003[3-9].png 004[0-9].png 005[0-9].png 006[0-4].png miff:- |\
	montage - -geometry 253x212+0+0 -tile 4x8 -background transparent miff:- | \
	convert - electric-locomotive-shadow-2.png

convert 006[5-9].png 007[0-9].png 008[0-9].png 009[0-6].png miff:- |\
	montage - -geometry 253x212+0+0 -tile 4x8 -background transparent miff:- | \
	convert - electric-locomotive-shadow-3.png

convert 009[7-9].png 010[0-9].png 011[0-9].png 012[0-8].png miff:- |\
	montage - -geometry 253x212+0+0 -tile 4x8 -background transparent miff:- | \
	convert - electric-locomotive-shadow-4.png

convert 0129.png 013[0-9].png 014[0-9].png 015[0-9].png 0160.png miff:- |\
	montage - -geometry 253x212+0+0 -tile 4x8 -background transparent miff:- | \
	convert - electric-locomotive-shadow-5.png

convert 016[1-9].png 017[0-9].png 018[0-9].png 019[0-2].png miff:- |\
	montage - -geometry 253x212+0+0 -tile 4x8 -background transparent miff:- | \
	convert - electric-locomotive-shadow-6.png

convert 019[3-9].png 020[0-9].png 021[0-9].png 022[0-4].png miff:- |\
	montage - -geometry 253x212+0+0 -tile 4x8 -background transparent miff:- | \
	convert - electric-locomotive-shadow-7.png

convert 022[5-9].png 023[0-9].png 024[0-9].png 025[0-6].png miff:- |\
	montage - -geometry 253x212+0+0 -tile 4x8 -background transparent miff:- | \
	convert - electric-locomotive-shadow-8.png
	