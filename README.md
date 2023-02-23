# Installation of dockerized Nextcloud instance behind a Nginx reverse proxy.

## Table of Contents:
[TOC]

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
**IMPORTANT**: 

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
