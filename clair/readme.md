# Work in Progress instructions

 mkdir $PWD/clair_config
 curl -L https://raw.githubusercontent.com/coreos/clair/master/config.yaml.sample -o $PWD/clair_config/config.yaml
 docker run -d -e POSTGRES_PASSWORD="" -p 5432:5432 postgres:9.6

 docker run --net=host -d -p 6060-6061:6060-6061 -v $PWD/clair_config:/config quay.io/coreos/clair-git:latest -config=/config/config.yaml