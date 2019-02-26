# How to split a tar file

## How to create:
You can pipe tar to the split command:

```
tar cvzf - dir/ | split --bytes=200MB - sda1.backup.tar.gz.
```
On some *nix systems (like OS X) you may get the following error:

split: illegal option -- -
In that case try this (note the -b 200m):

```
tar cvzf - dir/ | split -b 200m - sda1.backup.tar.gz.
```
If you happen to be trying to split file to fit on a FAT32 formatted drive use a byte limit of 4294967295. For example:

```
tar cvzf - /Applications/Install\ macOS\ Sierra.app/ | \
split -b 4294967295 - /Volumes/UNTITLED/install_macos_sierra.tgz.
```

# How to extract:

```
cat sda1.backup.tar.gz.* | tar xzvf
```
