# Traefik Setup

Using docker-compose to organize all of the information required to setup treafik. The workflow I have now is to push changes to Github then pull them down on the docker server. 

## HTTPS + AMCEv2 + LetsEncrypt
I'm using traefik's built in cert ability and DNS-01 challenage with Cloudflare.

Reference: https://docs.traefik.io/user-guides/docker-compose/acme-dns/

## Files

The compose file works in tune with a .env file and dynamic-conf.yaml file. 

You'll see that the commands section of the compose.yaml sets quite a few default parameters. ie entrypoints, dnschallenge, providers (docker, file), and misc other items.

 In the future for testing or changes, rather than taking down the proxy server we can adjust configurations in the dynamic-config.yaml file as traefik is configured to watch this for any updates.

 The directory structure is as follows: * are items you'll need to create. 
 ```
 --| traefik
 ----|docker-compose.yaml
 ----| dynamic-config.yaml
 ----| readme.md
 ----| .env *
 ----| data *
 ------| acme.json (this file must be locked down to 600 using chmod) *
 ------| traefik.log *
```

## .env file 

My .env file. This is a file I excluded from github so you'll have to create manually. 

``` 
CF_API_EMAIL=
CF_API_KEY=
CF_DNS_API_TOKEN=
CF_ZONE_API_TOKEN=
CF_API_EMAIL=
MYDNSCHALLENGE_ACME_EMAIL=
URL0_SAN=
URL_IP=
```

```URL0_SAN``` defines a designation for Traefik to route based on a http request for an address. ```URL0``` is simply the first URL to route ie ```traefik.site.local``` , and ```URL_IP``` is the IP address for routing as well ie ```192.168.1.12```. 

When a request hits traefik at ```traefik.site.local``` traefik will route to the service identified in the docker-compose file label.

Refer to the docker-compose.yaml file labels section: ```- "traefik.http.routers.api.rule=Host(`${URL0_SAN}`)"```

Remember .env files use a simple key-value pair and docker-compose will pull the value from the key associated with ```$``` or ```${key}```. 

 ## Providers

 ### Docker

 Of course we're using docker as a provider here. This means Traefik is assigned read-only access to the docker socket on the server. Here it'll watch for new containers and using labels we can define parameters for proxying. 

 Some things to note: 
 - We Set Docker to the "traefiknet" network created outside of the compose file
    - ``` docker create network traefiknet ```
- Traefik is set to not automatically route to containers.
    - We have to enable this by by using ``` traefik.enable=true ``` label .

 ### File
 We are setting this up for the future. The docker provider looks for things "dynamically" or at runtime of the container. The file provider gives us the option to set configurations that are not able to be set dynamically. 

 These do not always work however, I've found. 

 Once again though we've told Traefik to watch the yaml file we define. 
