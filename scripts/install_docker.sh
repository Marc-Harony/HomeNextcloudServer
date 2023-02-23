echo "This script will update your system, install and configure Docker CE"
echo "Press any key to continue or CTRL+C to abort"
read -n 1 -s



echo "#########################"
echo "# Configure Docker repo #"
echo "#########################"
dnf install -y dnf-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "#####################"
echo "# Install Docker CE #"
echo "#####################"
dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "#########################"
echo "# Conf users and groups #"
echo "#########################"
usermod -aG docker <your_user>
newgrp docker <<! >/dev/null 2>&1
exit
!

echo "#####################"
echo "# Configure SELinux #"
echo "#####################"
semanage permissive -a container_t

echo "###################"
echo "# Deactivate IPv6 #"
echo "###################"
cp /etc/sysctl.conf /etc/sysctl.conf.origin
sysctl -w net.ipv4.conf.all.forwarding=1 | tee -a /etc/sysctl.conf
sysctl -w net.ipv6.conf.all.disable_ipv6=1 | tee -a /etc/sysctl.conf
sysctl -w net.ipv6.conf.default.disable_ipv6=1 | tee -a /etc/sysctl.conf
sysctl --system #This loads settings into the running configuration without rebooting the server
# Check if the settings are applied:
sysctl net.ipv4.conf.all.forwarding
sysctl net.ipv6.conf.all.disable_ipv6
sysctl net.ipv6.conf.default.disable_ipv6

echo "#######################"
echo "# Edit Docker logging #"
echo "#######################"
touch /etc/docker/daemon.json
chmod 644 /etc/docker/daemon.json
chown root:root /etc/docker/daemon.json
echo '{' |  tee -a /etc/docker/daemon.json
echo '    "log-driver": "json-file",' |   tee -a /etc/docker/daemon.json
echo '    "log-opts": {'|  tee -a /etc/docker/daemon.json
echo '        "max-size": "200k",' |  tee -a /etc/docker/daemon.json
echo '        "max-file": "5",' |  tee -a /etc/docker/daemon.json
echo '        "mode": "non-blocking"' |  tee -a /etc/docker/daemon.json
echo '    }' |  tee -a /etc/docker/daemon.json
echo '}' |  tee -a /etc/docker/daemon.json

echo "###################"
echo "# Start Docker CE #"
echo "###################"
systemctl enable docker
systemctl start docker
systemctl status docker