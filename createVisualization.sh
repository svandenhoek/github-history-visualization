# Wrapper for gource that already has several settings configured to make sure it works properly
# with the generated output from previous phases.
# IMPORTANT: Do not run without giving an -<WIDTH>x<HEIGHT> argument!

# Explanation for some set arguments:
# --hide:
#		root is needed to make connections with root node invisible
#		bloom is disabled for making root node less clear (in large trees)
#		others are personal preference, though were added due to --hide using comma separated values
# --dir-name-depth 1:
#		allows for repository names to be shown (but disables all other directory names)
# --dir-name-position 1:
#		makes sure repository names are near their nodes
# --highlight-dirs:
#		makes sure directory names (so the repositories in this case) stay visible
# --seconds-per-day 0.08:
#		+/- 2 years per minute with no skipping
#		if changed, the time when the ROOT node/user appears might need to be tweaked as well for it
#		to dissapear before the actual changes are shown
# --disable-auto-skip:
#		no time skips and makes sure the ROOT user dissapears before the history starts to show

# Some suggestions for additional configuration:
# --key
# --title <string>
# --date-format <strftime time format> (f.e. "%Y-%m-%d")
# --dir-font-size <number>
# --user-scale <number>
# --caption-duration <number>
# --caption-size <number>
# --logo <path>
# --logo-offset <Y>x<X>

# The ffmpeg -ss removes the initial 8 seconds so that the creation of the ROOT user/node is not shown
# in the final output and the ROOT user should have faded away again before the video starts.

gource $@ --stop-at-end --disable-input \
--hide root,bloom,filenames,usernames \
--dir-name-depth 1 --dir-name-position 1 --highlight-dirs \
--seconds-per-day 0.082 --disable-auto-skip --max-file-lag 0.01 --file-idle-time 0 \
--caption-file ./gource_input/captions.txt \
--output-ppm-stream - ./gource_input/combined.txt \
| ffmpeg -r 60 -f image2pipe -vcodec ppm -i - \
-vcodec libx264 -preset medium -pix_fmt yuv420p -crf 1 -threads 0 -bf 0 -ss 8 gource.mp4
