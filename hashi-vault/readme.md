# Hashicorp Vault

## Overview

I'm using the arm32v6 image from docker hub. The storage provider is local file storage and i'm setting it to run in "production" mode via the command in the compose file. Everything is else is per usual on setup. Refer to the docker hub page on configuration options.

Initial setup i'm doing through the UI, but something like  ```docker exec -it vault bash``` plus cli commands will do the same. Vault's documents have setup done through the cli.

Recommend to run with "server" command option from github link I found. So doing that. 
=======
The intial setup for Vault want something like:
Root login -> admin and provisioner acls from docs -> admin token -> admin login 

### TL;DR
Some things to keep in mind: 
Vault is least privilege out of the box. The "default" acl is used for self management. The doc's admin profile is used to make overarching items, but not the same root access as root. 

When you create a new "engine" or place to store items they are at the "/whatever" path. So if you make a new key-vaule (kv) engine and name it "kv" as the default it'll be available at the "/kv" path in the configs.

You will need to make a new acls policy for the "engine" you make or use a wildcard. Then create tokens or as

#### Example 1, Wildcard:

```
# Access and Mange all Engines
path "/*"
{
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
```

#### Example 2, Specific: 

Key-value for cloudfare items.

```
path "kv-cloudflare/" {
  capabilities = ["read"]
}

path "kv-cloudflare/" {
  capabilities = ["list"]
}
```
## Setup

>Reference: https://learn.hashicorp.com/vault/identity-access-management/iam-policies

After running ```docker-compose up -d; docker-compose logs -f``` navigate to the URL via the browswer. Traefik already setup a https cert for us. We'll need to initialize the Vault. Once again this can be done through the cli.

### Policies

Use the pre-made policies from the docs to assign an admin and provisioner acl.

Create new client token via the new admin policy. ```vault write auth/token/create policies=admin``` and copy the contents to a safe place. This creates a token to be used as an admin.

Reference: https://www.vaultproject.io/docs/concepts/policies.html

### Tokens

Tokens are the initial and most basic form of authentication. Use the cli to create a token and use it during your api call to retrieve the secret.

```vault write auth/token/create policies=kv-it```

```
vault secrets enable -path=kv cloudflare
```

For userpass authentication add the name of the policy inside of the policy "Generated Token's Policies
" section. This will all the logged in user to have access to that acl.