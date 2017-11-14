# Git Tag Cheatsheet

## Remove all the tags:

#### Local:
```bash
git tag | xargs git tag -d
```

#### Remote:
```bash
git tag -l | xargs -n 1 git push --delete origin
```
