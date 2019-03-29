#!/usr/bin/env sh
_user="$(id -u -n)"

echo '**************************'
echo 'Installing misc dependencies'
echo '**************************'
# install dependencies
sudo apt-get update && sudo apt-get install systemd unzip wget build-essential make -y

echo '**************************'
echo 'Installing Ether-1 Node binary'
echo '**************************'
# Download node binary

wget https://ether1.org/releases/Ether1-MN-SN-0.0.6.tar.gz

tar -xzf Ether1-MN-SN-0.0.6.tar.gz

# Make node executable
chmod +x geth

# Remove and cleanup
rm Ether1-MN-SN-0.0.6.tar.gz

echo '**************************'
echo 'Creating and setting up system service'
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

ExecStart=/usr/sbin/geth --syncmode=fast --cache=512

[Install]
WantedBy=default.target
EOL
        sudo \mv /tmp/ether1node.service /etc/systemd/system
        sudo \mv geth /usr/sbin/
        sudo systemctl enable ether1node && systemctl start ether1node
        systemctl status ether1node --no-pager --full

echo '**************************'
echo 'Masternode Setup Complete....Deploying ethoFS'
echo '**************************'

#//install ipfs-cluster

cd $HOME
#wget http://149.28.193.106/ethofs.tar.gz
wget https://ether1.org/releases/ipfs.tar.gz
tar -xzf ipfs.tar.gz
chmod +x ipfs

# Remove and cleanup
rm ipfs.tar.gz

echo '**************************'
echo 'Creating and setting up ethoFS system service'
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

ExecStart=/usr/sbin/ipfs daemon --migrate

[Install]
WantedBy=default.target
EOL
        sudo \mv /tmp/ipfs.service /etc/systemd/system
        sudo \mv ipfs /usr/sbin/
        sudo setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/ipfs
        ipfs init
        ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/80
        sudo systemctl enable ipfs && systemctl start ipfs
        systemctl status ipfs --no-pager --full

cd $HOME
wget https://ether1.org/releases/ipfs-cluster-service.tar.gz
tar -xzf ipfs-cluster-service.tar.gz
chmod +x ipfs-cluster-service

# Remove and cleanup
rm ipfs-cluster-service.tar.gz

cat > /tmp/ipfsclusterservice.service << EOL
[Unit]
Description=IPFS Cluster Node System Service
After=network.target

[Service]
User=$_user
Group=$_user

Type=simple
Restart=always

ExecStart=/usr/sbin/ipfs-cluster-service daemon --upgrade --bootstrap /ip4/108.61.78.254/tcp/9096/ipfs/QmdedRzqxes6X67E5xgQSSK5CjWzB86jA31a77tUwFEvVs

[Install]
WantedBy=default.target
EOL
        sudo \mv /tmp/ipfsclusterservice.service /etc/systemd/system
        sudo \mv ipfs-cluster-service /usr/sbin/
        ipfs-cluster-service init
        sed -i -e "s/.*secret.*/\"secret\": \"f4541d02c72c0751481f49eeca90acd5be6829816774efd4a9247b9b33b0a7a0\",/" /home/$_user/.ipfs-cluster/service.json
        sudo systemctl enable ipfsclusterservice && systemctl start ipfsclusterservice
        systemctl status ipfsclusterservice --no-pager --full

echo '**************************'
echo 'ethoFS Setup Complete'
echo '**************************'
