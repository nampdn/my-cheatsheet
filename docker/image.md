# Docker images related command

## Docker remove unused image:
```docker rmi $(docker images -aq --filter dangling=true)```
