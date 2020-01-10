# How to use docker in docker

## Installation

### Mount docker.sock

```
docker run -p 8080:8080 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins \
  jenkins/jenkins:lts
```

### Install dependencies

```shell
sudo apt-get update \
&& sudo apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common \
&& curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > \
/tmp/dkey; sudo apt-key add /tmp/dkey && \
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" \
&& sudo apt-get update && sudo apt-get -y install docker-ce
```

### Update group

```
sudo usermod -aG docker <user>
```

### Update mounting permission

```bash
sudo chmod 666 /var/run/docker.sock
```

Reboot your container and try it:

```
docker ps
```
