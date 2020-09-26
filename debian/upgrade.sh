#!/usr/bin/env sh
[ $SUDO_USER ] && _user=$SUDO_USER || _user=`whoami`
_nodetype="masternode"

for opt in "$@"
do
  if [ $opt = "-masternode" ] ; then
    _nodetype="masternode"
  elif [ $opt = "-gatewaynode" ] ; then
    _nodetype="gatewaynode"
  elif [ $opt = "-servicenode" ] ; then
    _nodetype="servicenode"
  else
    echo "Invalid option: $opt"
  fi
done

if [ $_nodetype = "gatewaynode" ] ; then
  echo "ethoFS Gateway Node Setup Initiated"
fi
if [ $_nodetype = "masternode" ] ; then
  echo "Ether-1 Masternode Setup Initiated"
fi
if [ $_nodetype = "servicenode" ] ; then
  echo "Ether-1 Service Node Setup Initiated"
fi

echo '**************************'
echo 'Installing misc dependencies'
echo '**************************'
# install dependencies
sudo apt-get update && sudo apt-get install systemd libcap2-bin policykit-1 unzip wget -y

echo '**************************'
echo 'Removing Old Node bins'
echo '**************************'
# Remove Geth
sudo rm /usr/sbin/geth
sudo systemctl stop ether1node && sudo systemctl disable ether1node
sudo rm /etc/systemd/system/ether1node.service
# Remove IPFS
sudo rm /usr/sbin/ifps
sudo rm -r $HOME/.ipfs
sudo systemctl stop ipfs && sudo systemctl disable ipfs
sudo rm /etc/systemd/system/ipfs.service
# Remove ethoFS
sudo rm /usr/sbin/ethoFS
sudo systemctl stop ethoFS && sudo systemctl disable ethoFS
sudo rm /etc/systemd/system/ethoFS.service

echo '**************************'
echo 'Installing Ether-1 Node binary'
echo '**************************'
# Download node binary
wget https://github.com/Ether1Project/Ether-1-GN-Binaries/releases/download/1.3.0/Ether1-MN-SN-1.3.0.tar.gz
tar -xzf Ether1-MN-SN-1.3.0.tar.gz
# Make node executable
chmod +x geth
# Remove and cleanup
rm Ether1-MN-SN-1.3.0.tar.gz
# Move Binaries
sudo \mv geth /usr/sbin/

echo '**************************'
echo 'Initiating Kepler (Geth, IPFS & ethoFS)'
echo '**************************'

if [ $_nodetype = "gatewaynode" ] ; then
  sudo setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/geth
  /usr/sbin/geth --ethofs=gn --ethofsInit
  sleep 7
  /usr/sbin/geth --ethofs=gn --ethofsConfig
  sleep 7
  cat > /tmp/ether1node.service << EOL
  [Unit]
  Description=Ether1 Gateway Node
  After=network.target

  [Service]

  User=$_user
  Group=$_user

  Type=simple
  Restart=always

  ExecStart=/usr/sbin/geth --syncmode=fast --cache=512 --datadir=$HOME/.ether1 --ethofs=gn

  [Install]
  WantedBy=default.target
EOL
  sudo \mv /tmp/ether1node.service /etc/systemd/system
  sudo systemctl daemon-reload
  sudo systemctl enable ether1node && systemctl start ether1node
  sudo systemctl restart ether1node
  sudo systemctl status ether1node --no-pager --full
fi

if [ $_nodetype = "masternode" ] ; then
  /usr/sbin/geth --ethofs=mn --ethofsInit
  sleep 7
  /usr/sbin/geth --ethofs=mn --ethofsConfig
  sleep 7
  cat > /tmp/ether1node.service << EOL
  [Unit]
  Description=Ether1 Masternode
  After=network.target

  [Service]

  User=$_user
  Group=$_user

  Type=simple
  Restart=always

  ExecStart=/usr/sbin/geth --syncmode=fast --cache=512 --datadir=$HOME/.ether1 --ethofs=mn

  [Install]
  WantedBy=default.target
EOL
  sudo \mv /tmp/ether1node.service /etc/systemd/system
  sudo systemctl daemon-reload
  sudo systemctl enable ether1node && systemctl start ether1node
  sudo systemctl restart ether1node
  sudo systemctl status ether1node --no-pager --full
fi

if [ $_nodetype = "servicenode" ] ; then
  /usr/sbin/geth --ethofs=sn --ethofsInit
  sleep 7
  /usr/sbin/geth --ethofs=sn --ethofsConfig
  sleep 7
  cat > /tmp/ether1node.service << EOL
  [Unit]
  Description=Ether1 Service Node
  After=network.target

  [Service]

  User=$_user
  Group=$_user

  Type=simple
  Restart=always

  ExecStart=/usr/sbin/geth --syncmode=fast --cache=512 --datadir=$HOME/.ether1 --ethofs=sn

  [Install]
  WantedBy=default.target
EOL
  sudo \mv /tmp/ether1node.service /etc/systemd/system
  sudo systemctl daemon-reload
  sudo systemctl enable ether1node && systemctl start ether1node
  sudo systemctl restart ether1node
  sudo systemctl status ether1node --no-pager --full
fi

echo '**************************'
echo 'Setup Complete'
echo '**************************'
