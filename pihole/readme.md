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

## DHCP-Relay and DHCP
### Important part here: The pihole DHCP server will hand out the IP of the container. Override it with the IP of the raspberry pi.

Add the following line to your DHCP config in the "etc-dnsmaq.d" data folder:
```dhcp-option=option:dns-server,x.x.x.x```` 

You'll need to turn DHCP on in the pihole first for this file to exist. Either open the file and add the line or use a one liner. 

```echo "dhcp-option=option:dns-server,192.168.1.2" | sudo tee ./etc-dnsmasq.d/02-pihole-dhcp.conf```

Next set a hostname for your container in the docker-compose file. We'll need this for the relay to have a server to search for.

Also, we'll comment out the dhcp port in the compose file. The DHCP-relay will forward our traffic back and forth out of the container.

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
I'm using Method 2 .....after going with Method 1 first, but I like it everything being containerized. Minimal server setup is my preference. 

### Methood 1
#### Use a dhcp-relay on the raspberry pi to listen on an interface and forward requets to the container network. 

We'll add the interface we found above to the dhcp-relay configuration file.

Install the dhcp relay via apt.
``sudo apt install isc-dhcp-relay -y```

I've added my isc-dhcp-relay file for reference. The options used here will be set in the "options" on in the file.

```sudo service isc-dhcp-relay restart```
To monitor the logs tail ```tail -f /var/log/syslog``` to verify the deamon is starting properly. 

You can also use the debugging switch to verify your switches work as intended.Then write these swtiches to the OPTIONS section in the configuration files at ```/etc/default/isc-dhcp-relay```. 

 ```sudo dhcrelay -4 -d -id eth0 -iu br-976c9dfa3dbb pihole```

Remember to start the service once you've tested with the above command.
```sudo service isc-dhcp-relay restart```

Man page for the DHCP relay: https://manpages.debian.org/testing/isc-dhcp-relay/dhcrelay.8.en.html

## Method 2
### Use a seperate container and make it the relay. 
The second method is to define a second container, give this one network mode host, and stradle the necessary interfaces. 

This is a good reference used https://discourse.pi-hole.net/t/dhcp-with-docker-compose-and-bridge-networking/17038 
I like the idea of everything being in containers.

Need to use ```sudo docker-compose build``` for some reason. This needed to be run as sudo. It'll use the tag in the compose file to label the image. 

The docker-compose file lists the build image tag and necessary information for the container. Most importantly this container will have the network mode host option. Network mode host gives this container access to the host networking stack. It'll be able to forward UDP packets on the interfaces we specify. 

Give the dockerfile some build arguments: 
```
 args:
   INTERFACE_UPSTREAM: "br-976c9dfa3dbb"
   INTERFACE_DOWNSTREAM: "eth0"
   SERVER: "pihole"
 ```
 The upstream interface is the one where the DHCP server will be, and the downstream is where requests will originate. Last, the server is the hostname we defined in the compose file. This dockerfile could be refactored to manually add more interfaces if needed.
 
