# JQ Json Query

## Split from array into files

```shell
for f in `cat bible.json| jq -r 'keys[]'`; do
    cat bible.json | jq "[.[] | {Address, Book, Chapter, Verse, ScriptureVi, ScriptureEn}] | .[$f]" > ./bible/$f.json
done
```
