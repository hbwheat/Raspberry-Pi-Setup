# Pihole Setup on Raspberry Pi 4

## Files
Setup .env and data directories on the server. From point of docker-compose.yaml:

```
mkdir -p data/etc-pihole
mkdir data/dnsmasq.d
```
## Local DNS Settings
Adding 2 files is necessary along with one line for wildcards in the .conf file. 