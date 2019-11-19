# Rapsberry Pi Setup

## 1. Install OS

This guide does an excellent job of summarizing the steps: 
https://desertbot.io/blog/headless-raspberry-pi-4-ssh-wifi-setup

The gist...

You'll download the Raspbian Lite OS Image here:
https://www.raspberrypi.org/downloads/raspbian/

On Mac use balenaEtcher to write the os img file to the SD card.
https://www.balena.io/etcher/

Simply insert the SD card, boot up Etcher, and select the img downloaded. Then Etcher will take care of the rest.

Create a blank file on the root (the SD card will be labeled "boot", use the root of that drive) of the SD card titled "ssh". This tells Raspbian to start the ssh server on boot.

Insert the SD card into the Raspberry Pi, plug in ethernet and power.

View your DHCP logs/clients to get the IP of the device. You can also continually ping "raspberrypi.local" for the IP.

## 2. Connect and Configure

Once you have an IP of the fresh Pi, go ahead and connect to it.

Need to know: 
```
default hostname: raspberrypi
default username: pi
default password: raspberry
```
ssh into the raspberry pi
```
ssh pi@raspberrypi.local
```

Once in you have a plethora of options. To edit and change a slew of basic items related to the rapsberry pi use the following command. You'll be able to change the hostname, local, timezone, and other raspberry specific files. 
```
sudo raspi-config
```

### Static IP

To set a static IP we'll need to edit the ``` vi /etc/dhcpd.conf ``` file.

Default files: 

```
# A sample configuration for dhcpcd.
# See dhcpcd.conf(5) for details.

# Allow users of this group to interact with dhcpcd via the control socket.
#controlgroup wheel

# Inform the DHCP server of our hostname for DDNS.
hostname

# Use the hardware address of the interface for the Client ID.
clientid
# or
# Use the same DUID + IAID as set in DHCPv6 for DHCPv4 ClientID as per RFC4361.
# Some non-RFC compliant DHCP servers do not reply with this set.
# In this case, comment out duid and enable clientid above.
#duid

# Persist interface configuration when dhcpcd exits.
persistent

# Rapid commit support.
# Safe to enable by default because it requires the equivalent option set
# on the server to actually work.
option rapid_commit

# A list of options to request from the DHCP server.
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
# Respect the network MTU. This is applied to DHCP routes.
option interface_mtu

# Most distributions have NTP support.
#option ntp_servers

# A ServerID is required by RFC2131.
require dhcp_server_identifier

# Generate SLAAC address using the Hardware Address of the interface
#slaac hwaddr
# OR generate Stable Private IPv6 Addresses based from the DUID
slaac private

# Example static IP configuration:
#interface eth0
#static ip_address=192.168.0.10/24
#static ip6_address=fd51:42f8:caae:d92e::ff/64
#static routers=192.168.0.1
#static domain_name_servers=192.168.0.1 8.8.8.8 fd51:42f8:caae:d92e::1

# It is possible to fall back to a static IP if DHCP fails:
# define static profile
#profile static_eth0
#static ip_address=192.168.1.23/24
#static routers=192.168.1.1
#static domain_name_servers=192.168.1.1

# fallback to static profile on eth0
#interface eth0
#fallback static_eth0
```

We'll edit the above file to set a static IP. 

Add the following at the bottom of the file. I downloaded Vim:  ```sudo apt install vim -y```
```
interface eth0
static ip_address=192.168.1.12/24
static routers=192.168.1.1
static domain_name_servers=192.168.1.1 1.1.1.1
```
Save the file using "esc" key then ":qw" to quit and write the file to disk.
```sudo reboot``` to reboot the raspberry pi. I tried to restart networking and the dhcpd service however those did not reload the configuration file. 

Side note: this version of debian uses this config file for setting networking IP scheme. Previously ```/etc/networking/interfaces``` was used.

### Configure the Raspberry Pi

The world is your oyster now. You can do with your Pi as you please but you know have a headless Pi configured to be used over SSH. 

I'll continue with setting up Docker and other changes I will make with every install. 

#### Setup SSH Keys
 
 ```ssh-keygen ``` used defaults to place new ssh keys into the home folder of Pi. I'll be adding this public key to my Github account to pull in new items for development.

#### Git
```sudo apt install git -y```

#### Docker
Using this as a guide: https://docs.docker.com/v17.12/install/linux/docker-ce/debian/#install-using-the-repository

```
sudo apt-get update -y

sudo apt-get install -y \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

lsb_release -cs 

echo "deb [arch=armhf] https://download.docker.com/linux/debian \
     $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-get update -y 

sudo apt-get install docker-ce -y --no-install-recommends
```

The official Docker CE will try to install aufs-dkms as a dependency however it will fail. The default is to now use overlayfs2. This requires no changes on your part though. 
Reference: https://github.com/raspberrypi/linux/issues/3021#issuecomment-508704040

```
sudo apt remove aufs-dkms -y

sudo usermod -aG docker $USER

sudo docker run armhf/hello-world

sudo systemctl enable docker

sudo apt install python3-pip -y

sudo pip3 install docker-compose
```

#### Setup Files

```
sudo mkdir /srv/containers
sudo chown $USER:docker /srv/containers

git clone git@github.com:hbwheat/Raspberry-Pi-Setup.git /srv/containers

```

#### Setup Network for Traefik
```
sudo docker network create traefiknet
```


