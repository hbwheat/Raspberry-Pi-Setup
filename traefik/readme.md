# Traefik Setup

Using docker-compose to organize all of the information required to setup treafik. The workflow I have now is to push changes to Github then pull them down on the docker server. 


## Files

The compose file works in tune with a .env file and dynamic-conf.yaml file. 

You'll see that the commands section of the compose.yaml sets quite a few default parameters. ie entrypoints, dnschallenge, providers (docker, file), and misc other items.

 In the future for testing or changes, rather than taking down the proxy server we can adjust configurations in the dynamic-config.yaml file as traefik is configured to watch this for any updates.

 The directory structure is as follows: 
 ```
 --| traefik
 ----|docker-compose.yaml
 ----| dynamic-config.yaml
 ----| readme.md
 ----| .env
 ----| data
 ------| acme.json (this file must be locked down to 600 using chmod)
 ------| traefik.log
```

 ## Providers

 ### Docker

 Of course we're using docker as a provider here. This means Traefik is assigned read-only access to the docker socket on the server. Here it'll watch for new containers and using labels we can define parameters for proxying. 

 Some things to note: 
 - We Set Docker to the "traefiknet" network created outside of the compose file
    - ``` docker create network treafiknet ```
- Traefik is set to not automatically route to containers.
    - We have to enable this by by using ``` traefik.enable=true ``` label .

 ### File
 We are setting this up for the future. The docker provider looks for things "dynamically" or at runtime of the container. The file provider gives us the option to set configurations that are not able to be set dynamically. 

 These do not always work however, I've found. 

 Once again though we've told Traefik to watch the yaml file we define. 
