# How to spin up new production Ubuntu server

## Ubuntu:
* Setup main user:
```bash
# Switch to root (skip if you're already logged as root)
server$ sudo -i

# Add user name: demo
server# adduser demo

# Grant root permission for `demo` user
server# gpasswd -a demo sudo
```

* Add Public Key Authentication (On the local computer):
```bash
# Generate public/private key
local$ ssh-keygen

# Copy local public key to server
local$ ssh-copy-id demo@SERVER_IP_ADDRESS
```

* Update package:
```bash
demo$ sudo apt-get update
```

* Install required package:
```bash
demo$ sudo apt-get install -y wget curl zsh git
```


## Install Oh-my-zsh:
```bash
# Via CURL
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Or via WGET
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
```

## Install Node Version Manager (NodeJS):
```bash
# Via CURL
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

# Or via WGET
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

# Add PATH to .zshrc
vim ~/.zshrc

# At the end of the file add:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
```


## Install Docker:
```bash
wget -nv -O - https://get.docker.com/ | sh
```
