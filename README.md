# github-history-visualization
Visualize GitHub code history. Contains several steps for preprocessing 1 or more repositories (only 1 can currently be used for showing the releases) and some simple wrapper scripts for `gource` and `ffmpeg`.

## Requirements

- python3
  - sys
  - requests
  - datetime
- gource
- ffmpeg

## Example

```bash
mkdir myGourceDir
cd myGourceDir
sh visualizationPreprocessing.sh -g github_username/repo -i /local/path/to/repo [-i /local/path/to/repo]...
<<<<<<< HEAD
sh createVisualization.sh -1280x720 --key --title "myTitle" --date-format "%Y-%m-%d" --dir-font-size 20 --user-scale 3 --caption-duration 2 --caption-size 30 --logo /path/to/logo.png --logo-offset 10x10
=======
sh runGource.sh -1280x720 --key --title "myTitle" --date-format "%Y-%m-%d" --dir-font-size 20 --user-scale 3 --caption-duration 2 --caption-size 30 --logo /path/to/logo.png --logo-offset 10x10
sh runFfmpeg.sh
>>>>>>> origin/master
```

