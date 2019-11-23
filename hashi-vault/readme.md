# Hashicorp Vault

## Overview

I'm using the arm32v6 image from docker hub. The storage provider is local file storage and i'm setting it to run in "production" mode via the command in the compose file. Everything is else is per usual on setup. Refer to the docker hub page on configuration options.

Initial setup i'm doing through the UI, but something like  ```docker exec -it vault bash``` plus cli commands will do the same. Vault's documents have setup done through the cli.

Recommend to run with "server" command option from github link I found. So doing that. 

## Setup

>Reference: https://learn.hashicorp.com/vault/identity-access-management/iam-policies

After running ```docker-compose up -d; docker-compose logs -f``` navigate to the URL via the browswer. Traefik already setup a https cert for us. We'll need to initialize the Vault. Once again this can be done through the cli. 

### Policies

Use the pre-made policies from the docs to assign an admin and provisioner acl.

Create new client token via the new admin policy. ```vault write auth/token/create policies=admin``` and copy the contents to a safe place. 