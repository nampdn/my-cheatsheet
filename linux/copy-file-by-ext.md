# How to copy files recursive by extension

```
rsync -avm --include='*.txt' -f 'hide,! */' . /destination_dir
```

```
find .  -name '*.txt' -exec rsync -R {} path/to/dext \;
```
