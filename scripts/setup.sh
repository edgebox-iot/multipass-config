# If EDGEBOX_SYSTEM_PW is not set, set it to "pw"
if [ -z "$EDGEBOX_SYSTEM_PW" ]; then
    export EDGEBOX_SYSTEM_PW="pw"
fi

# Set DEBIAN_FRONTEND to noninteractive to prevent apt from asking for user input
export DEBIAN_FRONTEND=noninteractive

# Allow SSH access without public key
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart ssh

# Update apt
apt update

# Create user system and add to sudoers, set password to EDGEBOX_SYSTEM_PW
useradd -m -s /bin/bash system
echo "system:$(printenv EDGEBOX_SYSTEM_PW)" | chpasswd
usermod -aG sudo system

# Create docker group
groupadd docker

# Add system user to docker group
usermod -aG docker system

# Install dependencies

apt install -y docker.io python3-pip golang avahi-daemon avahi-utils
pip3 -v install docker-compose
pip3 -v install yq

# Fetch, build, and start edgebox components

mkdir /home/system/components
cd /home/system/components
git clone https://github.com/edgebox-iot/edgeboxctl.git
git clone https://github.com/edgebox-iot/ws.git
git clone https://github.com/edgebox-iot/api.git
git clone https://github.com/edgebox-iot/apps.git
cd ws
chmod 757 ws
mkdir appdata
chmod -R 777 appdata
./ws -b
cd /home/system/components/edgeboxctl
make build-prod
cp ./edgeboxctl.service /lib/systemd/system/edgeboxctl.service
cp ./bin/edgeboxctl /usr/local/sbin/edgeboxctl
systemctl daemon-reload
systemctl enable edgeboxctl
systemctl start edgeboxctl