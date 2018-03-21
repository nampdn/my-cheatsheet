# Generate ssh-keygen

```bash
# Generating public/private rsa key pair.
ssh-keygen -t rsa -b 4096 -C "@gmail.com"

# Start the ssh-agent in the background.
eval "$(ssh-agent -s)"

# Add your SSH private key to the ssh-agent
ssh-add ~/.ssh/id_rsa

# Display public key
cat ~/.ssh/id_rsa.pub
```
