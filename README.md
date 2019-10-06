# Ether-1 Node Installation Instructions

#### Servicenode running Ubuntu / Debian

```shell
apt-get update

apt-get upgrade -y

apt-get install wget

adduser ether1node

adduser ether1node sudo

adduser ether1node systemd-journal

mkdir -p /tmp/ether1 && cd /tmp/ether1

rm -rf servicenode.sh && wget https://raw.githubusercontent.com/Ether1Project/ether1-node-scripts/master/debian/servicenode.sh

chmod +x servicenode.sh

./servicenode.sh

sudo systemctl restart ether1node
```

#### Servicenode running CentOS / Fedora / Redhat

```shell
yum update -y

yum install wget systemd epel-release -y

adduser ether1node && passwd ether1node

usermod -aG wheel ether1node

mkdir -p /tmp/ether1 && cd /tmp/ether1

rm -rf install.sh && wget https://raw.githubusercontent.com/Ether1Project/ether1-node-scripts/master/rpm/servicenode.sh

chmod +x servicenode.sh

./servicenode.sh

sudo systemctl restart ether1node
```
#### Masternode running Ubuntu / Debian

```shell
apt-get update

apt-get upgrade -y

apt-get install wget

adduser ether1node

adduser ether1node sudo

adduser ether1node systemd-journal

mkdir -p /tmp/ether1 && cd /tmp/ether1

rm -rf setupETHOFS.sh && wget https://raw.githubusercontent.com/Ether1Project/ether1-node-scripts/master/debian/setupETHOFS.sh

chmod +x setupETHOFS.sh

./setupETHOFS.sh -masternode

sudo systemctl restart ether1node
```

#### Masternode running CentOS / Fedora / Redhat

```shell
yum update -y

yum install wget systemd epel-release -y

adduser ether1node && passwd ether1node

usermod -aG wheel ether1node

mkdir -p /tmp/ether1 && cd /tmp/ether1

rm -rf install.sh && wget https://raw.githubusercontent.com/Ether1Project/ether1-node-scripts/master/rpm/setupETHOFS.sh

chmod +x setupETHOFS.sh

./setupETHOFS.sh -masternode

sudo systemctl restart ether1node
```

#### Gateway Node running Ubuntu / Debian

```shell
apt-get update

apt-get upgrade -y

apt-get install wget

adduser ether1node

adduser ether1node sudo

adduser ether1node systemd-journal

mkdir -p /tmp/ether1 && cd /tmp/ether1

mkdir -p /tmp/ether1 && cd /tmp/ether1

rm -rf setupETHOFS.sh && wget https://raw.githubusercontent.com/Ether1Project/ether1-node-scripts/master/debian/setupETHOFS.sh

chmod +x setupETHOFS.sh

./setupETHOFS.sh -gatewaynode

sudo systemctl restart ether1node

sudo systemctl restart ipfs

sudo systemctl restart ethoFS
```

#### Gateway Node running CentOS / Fedora / Redhat

```shell

yum update -y

yum install wget systemd epel-release -y

adduser ether1node && passwd ether1node

usermod -aG wheel ether1node

mkdir -p /tmp/ether1 && cd /tmp/ether1

mkdir -p /tmp/ether1 && cd /tmp/ether1

rm -rf setupETHOFS.sh && wget https://raw.githubusercontent.com/Ether1Project/ether1-node-scripts/master/rpm/setupETHOFS.sh

chmod +x setupETHOFS.sh

./setupETHOFS.sh -gatewaynode

sudo systemctl restart ether1node

sudo systemctl restart ipfs

sudo systemctl restart ethoFS
```
