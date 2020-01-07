# Docker images related command

## Prune the system to the beginning

```docker system prune -a```

## Docker remove unused image:
```docker rmi $(docker images -aq --filter dangling=true)```

## List all exited containers
`docker ps -aq -f status=exited`

## Remove stopped containers
`docker ps -aq --no-trunc -f status=exited | xargs docker rm`
This command will not remove running containers, only an error message will be printed out for each of them.

## Remove dangling/untagged images
`docker images -q --filter dangling=true | xargs docker rmi`

## Remove containers created after a specific container
`docker ps --since a1bz3768ez7g -q | xargs docker rm`

## Remove containers created before a specific container
`docker ps --before a1bz3768ez7g -q | xargs docker rm`
Use --rm for docker build
Use --rm together with docker build to remove intermediary images during the build process.

# Docker - How to cleanup (unused) resources

Once in a while, you may need to cleanup resources (containers, volumes, images, networks) ...
    
## delete volumes
    
    // see: https://github.com/chadoe/docker-cleanup-volumes
    
    $ docker volume rm $(docker volume ls -qf dangling=true)
    $ docker volume ls -qf dangling=true | xargs -r docker volume rm
    
## delete networks

    $ docker network ls  
    $ docker network ls | grep "bridge"   
    $ docker network rm $(docker network ls | grep "bridge" | awk '/ / { print $1 }')
    
## remove docker images
    
    // see: http://stackoverflow.com/questions/32723111/how-to-remove-old-and-unused-docker-images
    
    $ docker images
    $ docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
    
    $ docker images | grep "none"
    $ docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')

## remove docker containers

    // see: http://stackoverflow.com/questions/32723111/how-to-remove-old-and-unused-docker-images
    
    $ docker ps
    $ docker ps -a
    $ docker rm $(docker ps -qa --no-trunc --filter "status=exited")
    
## Resize disk space for docker vm
    
    $ docker-machine create --driver virtualbox --virtualbox-disk-size "40000" default
    
