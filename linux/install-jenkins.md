# Install Jenkins
How To Install Jenkins on Ubuntu

## Step 1 — Installing Jenkins
```bash
# Add the repository key to the system.
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -

# Append the Debian package repository address to the server's sources.list:
echo deb https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list

# Run update so that apt-get will use the new repository:
sudo apt-get update

# Install Jenkins and its dependencies, including Java:
sudo apt-get install jenkins
```

## Step 2 — Starting Jenkins
```
update-rc.d jenkins enable
```

## Step 3 — Opening the Firewall
```
sudo ufw allow 8080
sudo ufw status
```

## Step 4 — Setting up Jenkins
Open: `http://ip_address_or_domain_name:8080`

```bash
# Get the password:
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Continue setup from Web UI!

