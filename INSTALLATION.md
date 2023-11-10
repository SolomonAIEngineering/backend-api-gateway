## Installation Instructions (For Dev)
### Install Jq (MAC OS X)
```bash
brew install jq
```

### LINUX
#### DEBIAN & UBUNTU
```bash
sudo apt-get install jq
```

#### FEDORA
```bash
sudo dnf install jq
```

### MAC OS X
The Homebrew formula will download the source code, build the binary, and link the binary for you. The installation might take a while.

Install krakenD using the `brew` command
```bash
brew install krakend
```

### LINUX
CentOS, Oracle Linux, and Redhat (yum)
The installation process requires following these steps:

1. Install the repo package
2. Install the KrakenD package
3. Start the KrakenD service

```bash
rpm -Uvh https://repo.krakend.io/rpm/krakend-repo-0.2-0.x86_64.rpm
yum install -y krakend
systemctl start krakend
```

#### Fedora
```bash
rpm -Uvh https://repo.krakend.io/rpm/krakend-repo-0.2-0.x86_64.rpm
dnf install -y krakend
systemctl start krakend
```

#### Debian & Ubuntu
The installation process requires following these steps:

1. Add the key
2. Add the repo to the sources.list
3. Update your package list
4. Install the KrakenD service
```bash
apt-key adv --keyserver keyserver.ubuntu.com --recv 5DE6FD698AD6FDD2
echo "deb https://repo.krakend.io/apt stable main" | tee /etc/apt/sources.list.d/krakend.list
apt-get update
apt-get install -y krakend
```