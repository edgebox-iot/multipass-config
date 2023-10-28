# If EDGEBOX_SYSTEM_PW is not set, set it to the first argument
if [ -z "$EDGEBOX_SYSTEM_PW" ]; then
    export EDGEBOX_SYSTEM_PW=$1
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

apt install -y docker.io python3-pip golang avahi-daemon avahi-utils restic jq
pip3 -v install docker-compose
pip3 -v install yq

# Install cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/download/2023.3.1/cloudflared-linux-$(printenv ARCH).deb
sudo dpkg -i cloudflared-linux-$(printenv ARCH).deb

# Fetch, build, and start edgebox components

mkdir /home/system/components
cd /home/system/components
git clone https://github.com/edgebox-iot/edgeboxctl.git
cd edgeboxctl
make build-$(printenv ARCH)
cp ./edgeboxctl.service /lib/systemd/system/edgeboxctl.service
cp ./bin/edgeboxctl /usr/local/sbin/edgeboxctl
cd ..
git clone https://github.com/edgebox-iot/ws.git
git clone https://github.com/edgebox-iot/api.git
git clone https://github.com/edgebox-iot/apps.git
cd ws
chmod 757 ws
mkdir appdata
chmod -R 777 appdata
systemctl daemon-reload
systemctl enable edgeboxctl
systemctl start edgeboxctl
./ws -b