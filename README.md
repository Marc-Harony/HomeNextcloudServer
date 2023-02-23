# Installation of dockerized Nextcloud instance behind a Nginx reverse proxy.

**IMPORTANT**: This README file AND the project is a work in progress. It is not finished yet. <br>

## Table of Contents:
[TOC]
- [Installation of dockerized Nextcloud instance behind a Nginx reverse proxy.](#installation-of-dockerized-nextcloud-instance-behind-a-nginx-reverse-proxy)
  - [Table of Contents:](#table-of-contents)
  - [Obectives:](#obectives)
- [About Docker](#about-docker)
  - [About Nextcloud](#about-nextcloud)
  - [About Nginx](#about-nginx)
  - [About this repository](#about-this-repository)
  - [About this README file](#about-this-readme-file)
  - [Prerequisites](#prerequisites)
  - [Good to know before starting](#good-to-know-before-starting)
    - [Docker's volumes](#dockers-volumes)
    - [Other folders in /mnt/nextcloud-configuration](#other-folders-in-mntnextcloud-configuration)
  - [Step 1: Install dependancies and configure the host](#step-1-install-dependancies-and-configure-the-host)


## Obectives:
- Install and configure a dockerized Nextcloud instance behind a Nginx reverse proxy
- Register to Let's Encrypt to get a free SSL certificate
- Configure Certbot to automatically renew the SSL certificate

# About Docker

Docker is a platform that utilizes open-source technology to facilitate the deployment, scaling, and management of applications within containers. Containers serve as self-contained, lightweight, and executable software packages that comprise all the essential components necessary to run an application, such as the code, runtime, libraries, system tools, and settings.<br>
With Docker, developers can streamline the development and deployment process by encapsulating their applications in containers that can operate reliably on any system, including a developer's laptop, test environment, or production server. Moreover, Docker offers a centralized system for managing and orchestrating containers, enabling developers to manage and scale their applications efficiently in a production environment.<br>
In summary, Docker is a platform that facilitates the creation, packaging, and deployment of applications in containers, ensuring a consistent and effective approach to running applications in any setting.

## About Nextcloud

Nextcloud is a self-hosted file sync and share server. It is a fork of ownCloud, which was acquired by the German company Nextcloud GmbH in 2016. Nextcloud is free and open-source, and is licensed under the GNU General Public License version 2 or later.

## About Nginx

Nginx (pronounced "engine-x") is a web server which can also be used as a reverse proxy, load balancer, mail proxy and HTTP cache. The software was created by Igor Sysoev and first publicly released in 2004. A company of the same name was founded in 2011 to provide support and Nginx Plus, a proprietary add-on to the open source version.

## About this repository

This repository contains a docker-compose file to run a Nextcloud instance behind a Nginx reverse proxy. It is based on the official Nextcloud docker image and the official Nginx docker image.

## About this README file

In this document, you will fin all required information on how to install and configure Nextcloud form scratch on Oracle Linux (OL) <br>
Keep in mind that the information provided in this README file may not match your own situation, as it could be specific to a different version of the distro you are using or to a newer version of Nextcloud, Nginx or Docker <br>

## Prerequisites

- A server with a fresh installation of an Hardened version of Oracle Linux with Generic Application Server profile
- A user with sudo privileges

## Good to know before starting

### Docker's volumes
We are using volumes to store persistant datas and avoid data loss each time a docker service is putted down. <br>
This consists of a mapping between a directory on the host file system and a directory inside the Docker service container. <br>
More information about Docker's volumes are available here: https://docs.docker.com/storage/
<br>
<br>
Volumes are configured into the docker-compose.yaml file. <br>
The volume that contains configuration files is mounted from /mnt/nextcloud-configuration <br>
The volume that contains the data is mounted from /mnt/nextcloud-data <br>
The data, the OS and the configuration files are stored on different volumes to avoid data loss in case of a server crash. <br>

|Docker's services|Volume|Usage|
|:---|:--|:--|
|**All Dockers' services**|`/etc/localtime:/etc/localtime:ro`|Needed to synchronize the time between the host and the container.|
|**All Dockers' services**|`/etc/localtime:/etc/timezone:ro`|Needed to synchronize the time between the host and the container.|
|**Docker itself**|`/var/run/docker.sock:/var/run/docker.sock:ro`|Needed to allow the docker service to communicate with each other.|
|**Nextcloud**|`/mnt/nextcloud-configuration/nextcloud:/var/www/html:rw`|Nextcloud configuration files. Themes; database, ... are stored here.|
|**Nextcloud**|`/mnt/nextcloud-data/data:/var/www/html/data:rw`|Nextcloud data files. As said previously, this mount point is in another volume to avoid data loss in case of a server crash.|
|**Nginx**|`/mnt/nextcloud-configuration/nginx:/etc/nginx:rw`|Nginx configuration files.|

*- `ro` is for read-only so the container cannot directly write the file/directory*<br>
*- `rw` is for read-write so the container can directly write the file/directory*<br>
*NB: Note that the `ro` option is not mandatory, it is just a good practice to avoid any misinterpretation.*

### Other folders in /mnt/nextcloud-configuration
|Folder|Usage|
|:-----|:----|
|`/mnt/nextcloud-configuration/docker-compose`|This folder contains the docker-compose.yaml file.|

## Step 1: Install dependancies and configure the host
A script is available to automate the installation of Docker. You can find it [here](https://github.com/Marc-Harony/HomeNextcloudServer/blob/master/scripts/install_docker.sh). <br>
To launch the script, run the following commands:
```bash
sudo chmod +x /path/to/script/install_docker.sh
sudo /path/to/script/install_docker.sh
```
Or you can follow the steps below:

1) Update your system
```bash
sudo dnf update -y
```
2) Install Docker
```bash
#########################
# Configure Docker repo #
#########################
sudo dnf install -y dnf-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

#####################
# Install Docker CE #
#####################
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

#########################
# Conf users and groups #
#########################
sudo usermod -aG docker <your_user>
sudo newgrp docker <<! >/dev/null 2>&1
exit
!

#####################
# Configure SELinux #
#####################
sudo semanage permissive -a container_t

###################
# Deactivate IPv6 #
###################
sudo cp /etc/sysctl.conf /etc/sysctl.conf.origin
sudo sysctl -w net.ipv4.conf.all.forwarding=1 | tee -a /etc/sysctl.conf
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 | tee -a /etc/sysctl.conf
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 | tee -a /etc/sysctl.conf
sudo sysctl --system #This loads settings into the running configuration without rebooting the server
# Check if the settings are applied:
sudo sysctl net.ipv4.conf.all.forwarding
sudo sysctl net.ipv6.conf.all.disable_ipv6
sudo sysctl net.ipv6.conf.default.disable_ipv6

#######################
# Edit Docker logging #
#######################
sudo touch /etc/docker/daemon.json
sudo chmod 644 /etc/docker/daemon.json
sudo chown root:root /etc/docker/daemon.json
echo '{' | sudo tee -a /etc/docker/daemon.json
echo '    "log-driver": "json-file",' | sudo  tee -a /etc/docker/daemon.json
echo '    "log-opts": {'| sudo tee -a /etc/docker/daemon.json
echo '        "max-size": "200k",' | sudo tee -a /etc/docker/daemon.json
echo '        "max-file": "5",' | sudo tee -a /etc/docker/daemon.json
echo '        "mode": "non-blocking"' | sudo tee -a /etc/docker/daemon.json
echo '    }' | sudo tee -a /etc/docker/daemon.json
echo '}' | sudo tee -a /etc/docker/daemon.json

##########################
# Configure the firewall #
##########################
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp --add-port=80/udp
sudo firewall-cmd --permanent --zone=public --add-port=443/tcp --add-port=443/udp
sudo firewall-cmd --reload

####################
# Start Docker CE #
####################
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl status docker
```
