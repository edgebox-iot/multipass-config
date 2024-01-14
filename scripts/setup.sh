# If EDGEBOX_SYSTEM_PW is not set, set it to the first argument
if [ -z "$EDGEBOX_SYSTEM_PW" ]; then
    export EDGEBOX_SYSTEM_PW=$1
fi

# If CLUSTER_HOST is not set, set it to the second argument
if [ -z "$EDGEBOX_CLUSTER_HOST" ]; then
    export EDGEBOX_CLUSTER_HOST=$2
fi

# Get current system architecture (and normalize to POSIX standard)
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
    export ARCH="arm64"
fi

if [  "$ARCH" = "armv7l" ]; then
    export ARCH="arm"
fi

if [  "$ARCH" = "x86_64" ]; then
    export ARCH="amd64"
fi

# Set DEBIAN_FRONTEND to noninteractive to prevent apt from asking for user input
export DEBIAN_FRONTEND=noninteractive

# Create user system and add to sudoers, set password to EDGEBOX_SYSTEM_PW
useradd -m -s /bin/bash system
echo "system:$(printenv EDGEBOX_SYSTEM_PW)" | chpasswd
usermod -aG sudo system

# Set root password as EDGEBOX_SYSTEM_PW
echo "root:$(printenv EDGEBOX_SYSTEM_PW)" | chpasswd

# Allow SSH access without public key
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Allow root ssh login
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl restart ssh

# Update apt
apt update

# Create docker group
groupadd docker

# Add system user to docker group
usermod -aG docker system

# Install dependencies
apt install -y docker.io python3-pip golang avahi-daemon avahi-utils restic jq apache2-utils
pip3 -v install docker==6.1.3
pip3 -v install docker-compose
pip3 -v install yq

# Install cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/download/2023.3.1/cloudflared-linux-$(printenv ARCH).deb
sudo dpkg -i cloudflared-linux-$(printenv ARCH).deb

# Install sshx
curl -sSf https://sshx.io/get | sh

# Fetch, build, and start edgebox components

# Create directory structure
# Clone components
mkdir /home/system/components
cd /home/system/components
git clone https://github.com/edgebox-iot/ws.git
git clone https://github.com/edgebox-iot/api.git
git clone https://github.com/edgebox-iot/apps.git
git clone https://github.com/edgebox-iot/logger.git
git clone https://github.com/edgebox-iot/edgeboxctl.git

# Install Logger
cd logger
make install
cd ..

# Setup cloud env and build edgeboxctl
cd edgeboxctl
# Check if the file /home/ubuntu/cloud.env exists. If it does, copy it to /home/system/components/api
if [ -f /home/ubuntu/cloud.env ]; then
    cp /home/ubuntu/cloud.env /home/system/components/api/cloud.env
    make install-cloud
else
    # Get curent system architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "aarch64" ]; then
        make install-arm64
    fi
    if [ "$ARCH" = "armv7l" ]; then
        make install-armhf
    fi
    if [ "$ARCH" = "x86_64" ]; then
        make install-amd64
    fi
fi
cd ..

# Prep ws permissions
cd ws
chmod 757 ws
mkdir appdata
chmod -R 777 appdata
cd ..

# Check if EDGEBOX_CLUSTER_HOST is not empty
if [ -n "$EDGEBOX_CLUSTER_HOST" ]; then
    # build add cluster host to api conf
    # Configure Dashboard Host
    cd api
    touch myedgeapp.env
    echo "INTERNET_URL=$EDGEBOX_CLUSTER_HOST" >> myedgeapp.env
    cd ..
fi

# Reload deamon, enable, and start services
systemctl daemon-reload
systemctl enable edgeboxctl
systemctl start edgeboxctl
systemctl enable logger
systemctl start logger

# Add motd
# Create motd file
cat << EOF > /etc/motd
          #######                                                             
       #############                                                          
   ########  #  #######                                                       
   ####   #######  #####    #####     ##               ##                     
   ####################     ####   #####  #####  ####  #####  #####  ## ##    
   ####################     ##     ## ##  #  ## #####  ##  #  ## ##   ###     
   ####  ########  #####    #####   ####  #####  ####  #####   ###   ## ##    
   #######   #  ########                   ###                                
       #############                                                          
         ########                                                             
                                                                                            
You're connected to the Edgebox system via terminal. 
This provides administrator capabilities and total system access.
If you're developing for Edgebox, please refer to https://docs.edgebox.io

This software comes with ABSOLUTELY NO WARRANTY, 
to the extent permitted by applicable law.

EOF

# add a line to print it on /root/.bashrc
echo "cat /etc/motd" >> /root/.bashrc

# Start Web Server
cd ws
./ws -b
