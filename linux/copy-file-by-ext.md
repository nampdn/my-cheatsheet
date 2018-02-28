# How to copy files recursive by extension

```
rsync -avm --include='*.txt' -f 'hide,! */' . /destination_dir
```
