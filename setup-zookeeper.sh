#!/bin/bash

######
# NOTE: At "Zookeeper config creation" step it will generate a working config for zookeeper, but there is a caveat. 
# As for the ensemble member config, you would manually need to edit each member's config and include their private IP address so they can form up a quorum
# Replace these values {output.ec2_instance*.private_ip} with your AWS EC2 instance private IP addresses
######

touch /var/tmp/setup.log

# Disable interactive confirmations during library updates
sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

# Install java, pgp key verification tool
apt-get update
apt upgrade -y
apt install pgpgpg -y
apt install openjdk-19-jre-headless -y

java -version >> /var/tmp/setup.log
if [ $? -eq 0 ]; then
    echo "Java installation completed, moving on with next step" >> /var/tmp/setup.log
else
    echo "Failed installing java" >> /var/tmp/setup.log
    exit 1
fi

# Setup zookeeper user and download files, change ownership etc
useradd --shell /sbin/nologin zookeeper
mkdir /opt/zookeeper
cd /opt/zookeeper

####################################
### Perform the following steps (package downloading and checksum) as part of building a golden image, so you have it ready to use
# Using it here to show how to do it in a single go
####################################
wget https://dlcdn.apache.org/zookeeper/zookeeper-3.9.1/apache-zookeeper-3.9.1-bin.tar.gz
tar -xvf apache-zookeeper-*
mv apache-zookeeper-3.9.1-bin/* .
rm -rf apache-zookeeper-3.9.1-bin


######### The following steps can be used for when you want to create your golden image to check integrity of the download you did above, doing it in user-script is an overkill
# Commented to just keep them in the script for explanation 
# wget https://dlcdn.apache.org/zookeeper/KEYS
# gpg --import KEYS
# wget https://dlcdn.apache.org/zookeeper/zookeeper-3.9.1/apache-zookeeper-3.9.1-bin.tar.gz.asc
# pgp -ka KEYS
# pgp apache-zookeeper-3.9.1-bin.tar.gz.asc
# chown -R zookeeper:zookeeper /opt/zookeeper
# cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg
#########


# Mount EBS here
partition_table=`fdisk -l | grep -o "/dev/xvdh"`

if [ $? -eq 0 ]; then
    echo "EBS block present in partition table" >> /var/tmp/setup.log
    parted --script /dev/xvdh mklabel gpt
    parted --script /dev/xvdh mkpart primary 1 1024MB
    sleep 10
    mkfs.xfs /dev/xvdh1
    mkdir /opt/zookeeper-data
    chown -R zookeeper:  /opt/zookeeper-data
    echo "/dev/xvdh1      /opt/zookeeper-data       xfs     defaults 0 0" >> /etc/fstab
    mount -a 
    df -h | grep '/opt/zookeeper-data' | tee /var/tmp/setup.log
else
    echo "EBS block is not attached to machine" >> /var/tmp/setup.log
    exit 1
fi

# Check file system is mounted properly
df -h | grep "/opt/zookeeper-data"
if [ $? -eq 0 ]; then
    echo "EBS block mounted" >> /var/tmp/setup.log
else
    echo "EBS block mounting failed" >> /var/tmp/setup.log
fi


#### Zookeeper configuration creation

cat <<EOF > /opt/zookeeper/conf/zoo.cfg
# The number of milliseconds of each tick
tickTime=2000

# The number of ticks that the initial synchronization phase can take
initLimit=10

# The number of ticks that can pass between sending a request and getting an acknowledgement
syncLimit=5

# the directory where the snapshot is stored.
dataDir=/opt/zookeeper-data

# the port at which the clients will connect
clientPort=2181

# the maximum number of client connections - increase this if you need to handle more clients
maxClientCnxns=60

# The number of snapshots to retain in dataDir
autopurge.snapRetainCount=3

# Purge task interval in hours - Set to "0" to disable auto purge feature
autopurge.purgeInterval=1

## Metrics Providers
# https://prometheus.io Metrics Exporter
metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider
metricsProvider.httpHost=0.0.0.0
metricsProvider.httpPort=7000
metricsProvider.exportJvmInfo=true
				
# 4 letter words
4lw.commands.whitelist=stat, ruok, conf, isro
4lw.commands.whitelist=*

# Ensemble configuration
server.1={output.ec2_instance1.private_ip}:2888:3888
server.2={output.ec2_instance2.private_ip}:2888:3888
server.3={output.ec2_instance3.private_ip}:2888:3888
EOF

cat <<EOF > /etc/systemd/system/zookeeper.service
[Unit]
Description=Zookeeper Daemon
Documentation=http://zookeeper.apache.org
Requires=network.target
After=network.target

[Service]
Type=forking
WorkingDirectory=/opt/zookeeper
User=zookeeper
Group=zookeeper
ExecStart=/opt/zookeeper/bin/zkServer.sh start /opt/zookeeper/conf/zoo.cfg
ExecStop=/opt/zookeeper/bin/zkServer.sh stop /opt/zookeeper/conf/zoo.cfg
ExecReload=/opt/zookeeper/bin/zkServer.sh restart /opt/zookeeper/conf/zoo.cfg
TimeoutSec=30
Restart=on-failure
		
[Install]
WantedBy=default.target
EOF

chown -R zookeeper: /opt/zookeeper

sudo systemctl daemon-reload
sudo systemctl enable zookeeper

# sudo systemctl start zookeeper
