# CHMOD make file accessible

One approach could be using find:

- for directories:

`find . -type d -print0 | xargs -0 chmod 0755`

- for files:

`find . -type f -print0 | xargs -0 chmod 0644`
