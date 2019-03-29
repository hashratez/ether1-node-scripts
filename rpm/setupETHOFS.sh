#!/usr/bin/env sh
_user=${SUDO_USER:-$(whoami)}
_upgrade="No"
_nodetype="masternode"

for opt in "$@"
do
 if [ $opt = "-servicenode" ] ; then
    _nodetype="servicenode"
 elif [ $opt = "-masternode" ] ; then
    _nodetype="masternode"
 elif [ $opt = "-gatewaynode" ] ; then
    _nodetype="gatewaynode"
 elif [ $opt = "-upgrade" ] ; then
    _upgrade="Yes"
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
if [ $_upgrade = "Yes" ] ; then
    echo "Upgrade Option Selected"
fi

echo '**************************'
echo 'Installing misc dependencies'
echo '**************************'
# install dependencies
sudo yum install unzip wget -y

echo '**************************'
echo 'Installing Ether-1 Node binary'
echo '**************************'
# Download node binary

wget https://files.ether1.org/releases/Ether1-MN-SN-0.0.9.1.tar.gz

tar -xzf Ether1-MN-SN-0.0.9.1.tar.gz

# Make node executable
chmod +x geth

# Remove and cleanup
rm Ether1-MN-SN-0.0.9.1.tar.gz

echo '**************************'
echo 'Creating and setting up Masternode/Service Node system service'
echo '**************************'

cat > /tmp/ether1node.service << EOL
[Unit]
Description=Ether1 Masternode/Service Node
After=network.target

[Service]

User=$_user
Group=$_user

Type=simple
Restart=always

ExecStart=/usr/sbin/geth --syncmode=fast --cache=512 --datadir=/home/$_user/.ether1

[Install]
WantedBy=default.target
EOL
        sudo systemctl stop ether1node
        sudo \mv /tmp/ether1node.service /etc/systemd/system
        sudo \mv geth /usr/sbin/
        sudo systemctl daemon-reload
        sudo systemctl enable ether1node && systemctl start ether1node
        sudo systemctl restart ether1node
        sudo systemctl status ether1node --no-pager --full

echo '**************************'
echo 'Masternode Setup Complete....Deploying IPFS'
echo '**************************'

cd /home/$_user
wget https://files.ether1.org/releases/ipfs.tar.gz
tar -xzf ipfs.tar.gz
chmod +x ipfs

# Remove and cleanup
rm ipfs.tar.gz

echo '**************************'
echo 'Creating and setting up IPFS system service'
echo '**************************'

cat > /tmp/ipfs.service << EOL
[Unit]
Description=IPFS Node System Service
After=network.target

[Service]
User=$_user
Group=$_user

Type=simple
Restart=always

ExecStart=/usr/sbin/ipfs daemon --migrate --enable-namesys-pubsub --enable-gc

[Install]
WantedBy=default.target
EOL
        sudo systemctl stop ipfs
        sudo \mv /tmp/ipfs.service /etc/systemd/system
        sudo \mv ipfs /usr/sbin/
        if [ $_upgrade = "No" ] ; then
            sudo rm -r $HOME/.ipfs
            sudo rm -r /home/$_user/.ipfs
            ipfs init
        fi
        ipfs bootstrap rm --all
        if [ $_nodetype = "gatewaynode" ] ; then
            _maxstorage="78GB"
            sudo setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/ipfs
            ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/80
        fi
        if [ $_nodetype = "masternode" ] ; then
            _maxstorage="38GB"
        fi
        if [ $_nodetype = "servicenode" ] ; then
            _maxstorage="18GB"
        fi
        ipfs config Datastore.StorageMax $_maxstorage
        ipfs config --json Swarm.ConnMgr.LowWater 400
        ipfs config --json Swarm.ConnMgr.HighWater 600
        ipfs bootstrap add /ip4/207.148.27.84/tcp/4001/ipfs/QmTFUcUuMSN7KLytjtqnHCjixqd4ig3PrSbdQ2mW9Q8qeY
        ipfs bootstrap add /ip4/66.42.109.75/tcp/4001/ipfs/QmV856mLWnTDaj5LQvS3dCa3qjz4DNC9cKQJNSrwtqcHzT
        ipfs bootstrap add /ip4/95.179.136.216/tcp/4001/ipfs/QmdFCa2ix51sV8FADGKDadKPGB55kdEQMZm9VKVSRTbVhC
        ipfs bootstrap add /ip4/45.63.116.102/tcp/4001/ipfs/QmSfEKCzPWA6MmG2ZLK4Vqnq6oB6rvrLyUpHdNqng5nQ4t
        ipfs bootstrap add /ip4/149.28.167.176/tcp/4001/ipfs/QmRwQ49Zknc2dQbywrhT8ArMDS9JdmnEyGGy4mZ1wDkgaX
        ipfs bootstrap add /ip4/140.82.54.221/tcp/4001/ipfs/QmeG81bELkgLBZFYZc53ioxtvRS8iNVzPqxUBKSuah2rcQ
        ipfs bootstrap add /ip4/45.77.170.137/tcp/4001/ipfs/QmTZsBNb7dfJJmwuAdXBjKZ7ZH6XbpestZdURWGJVyAmj2
        sudo mv $HOME/.ipfs /home/$_user/
        sudo chown -R $_user:$_user /home/$_user/.ipfs

cat > /tmp/swarm.key << EOL
/key/swarm/psk/1.0.0/
/base16/
38307a74b2176d0054ffa2864e31ee22d0fc6c3266dd856f6d41bddf14e2ad63
EOL
        sudo \mv /tmp/swarm.key /home/$_user/.ipfs
        sudo systemctl daemon-reload
        sudo systemctl enable ipfs && systemctl start ipfs
        sudo systemctl restart ipfs
        sudo systemctl status ipfs --no-pager --full

echo '**************************'
echo 'IPFS Setup Complete....Deploying ethoFS'
echo '**************************'
cd /home/$_user
wget https://files.ether1.org/releases/ethoFS.tar.gz
tar -xzf ethoFS.tar.gz
chmod +x ethoFS

# Remove and cleanup
rm ethoFS.tar.gz

echo '**************************'
echo 'Creating and setting up ethoFS system service'
echo '**************************'

cat > /tmp/ethoFS.service << EOL
[Unit]
Description=ethoFS Node System Service
After=network.target

[Service]
User=$_user
Group=$_user

Type=simple
Restart=always

ExecStart=/usr/sbin/ethoFS -$_nodetype

[Install]
WantedBy=default.target
EOL
        sudo systemctl stop ethoFS
        sudo \mv /tmp/ethoFS.service /etc/systemd/system
        sudo \mv ethoFS /usr/sbin/
        sudo systemctl daemon-reload
        sudo systemctl enable ethoFS && systemctl start ethoFS
        sudo systemctl restart ethoFS
        sudo systemctl status ethoFS --no-pager --full
echo '**************************'
echo 'ethoFS Setup Complete'
echo '**************************'
