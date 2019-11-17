# Pihole Setup on Raspberry Pi 4

## Files
Setup .env and data directories on the server. From point of docker-compose.yaml:

```
mkdir -p data/etc-pihole
mkdir data/dnsmasq.d
```

The etc-pihole folder will hold persistent data. We'll add a new config to the dnsmasq.d direcotry to act like split-brain dns for a domain. In my case hbwheat.dev.

Create a single text file with a line telling the pihole dns to send all dns traffic based on teh wild card *.hbwheat.dev towards the ip of the server. I'll also add a .list file for reference in the persistent data folder for future use. This will allow me to define IPs as necessary and be served by the pihole dns server.

```
addn-hosts=/etc/pihole/01.locallan.list
address=/hbwheat.dev/192.168.1.12
```

## Local DNS Settings
Adding 2 files is necessary along with one line for wildcards in the .conf file.

https://qiita.com/bmj0114/items/9c24d863bcab1a634503

## DHCP
Set a hostname for your container in the docker-compose file. We'll need this for the relay to have a server to search for.

Also, we'll comment out the dhcp port in the compose file. The DHCP relay will forward our traffic back and forth out of the container.

Setting up a DHCP server within a container has a simple challenge. DHCP packets don't traverse over subnets. The way docker handles bridging of networks, if you wish to have a container not be on the host network you'll need to configure your server with a dhcp relay.

The relay will sit on both the docker network bridge for the dhcp server and the client request side.

We'll need to define a network outside of the compose file for Pihole to use. Before we do that, let's check out the route table on the server to determine what the interfaces are and then we can figure out the name of the new network interface.

```
ip route
```

Then create a new network for docker:
```
docker network create piholedhcp
```

Bring up ip routes again and lets see the new networking scheme. The new network interface will be towards the bottom of the list and look something like ```br-976c9dfa3dbb```

```
ip route
```

We'll add this interface to the dhcp-relay configuration file. Install the dhcp relay via apt.
``sudo apt install isc-dhcp-relay -y```

I've added my isc-dhcp-relay file for reference. The options used here will be set in the "options" on in the file.

```sudo service isc-dhcp-relay restart```
To monitor the logs tail ```tail -f /var/log/syslog``` to verify the deamon is starting properly. 

You can also use the debugging switch to verify your switches work as intended.
 ```sudo dhcrelay -4 -d -id eth0 -iu br-976c9dfa3dbb pihole```

Remember to start the service once you've tested: ```sudo service isc-dhcp-relay restart```

Man page for the DHCP relay: https://manpages.debian.org/testing/isc-dhcp-relay/dhcrelay.8.en.html

Alternative https://discourse.pi-hole.net/t/dhcp-with-docker-compose-and-bridge-networking/17038 I like the idea of everything being in containers. I'll need to look at this more. 

Trying with a seperate container. 
Need to use ```sudo docker-compose build```

Two option now.... 
1. use server
2. use container services to forward dhcp requests and replies. 

Add ```dhcp-option=option:dns-server,x.x.x.x```` to the dhcp conf file in the "etc-dnsmasq.d" data directory. 