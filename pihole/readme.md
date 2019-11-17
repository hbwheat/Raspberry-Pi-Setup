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

