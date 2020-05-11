# ELK Stack
## Description
This repository was made to be able to deploy a quick and secure Elasticsearch Stack.
It was heavily inspired by [elastdocker](https://github.com/sherifabdlnaby/elastdocker).

## PLEASE NOTE 

This project is under development. Some things must be taken in considerations
to guarantee the environment to be fully secure.

More information about this will be documented soon.

### Features

- Production Single Node Cluster.
- Self-Monitoring Metrics Enabled.
- Security Enabled (under basic license).
- SSL Enabled for Elasticsearch, Kibana and Logstash on both HTTP and transport layer.
- Automatic certificates, keystores and passwords generation.

## Requirements

- [Docker >= 17.05](https://docs.docker.com/install/)
- [Docker-Compose >= 3](https://docs.docker.com/compose/install/)
- Increase system limits on mmap counts using `sysctl -w vm.max_map_count=262144` and `sysctl -p` to reload.

To set this value permanently, update the vm.max_map_count setting in /etc/sysctl.conf. To verify after rebooting, run sysctl vm.max_map_count.

## Usage:    
```
git clone https://github.com/antoinethebuilder/elk/elk.git && \
cd elk && \
sudo make all
```

For more options, type `make` or `make help`.

### How it works

1. Run temporary service called "_elastic_keystore_" to define the "_bootstrap.password_"
2. Generate certificates from the instances defined in "_setup/instances.yml_"
3. Build and run the elasticsearch service
4. Run the script "_setup/gen-password.sh_"
    - Create the logstash user and role
    - Use "_elasticsearch-setup-passwords_" to generate password of built-in users
    - Write the password to the file "_secrets/pass/passfile.txt_"
5. Run temporary services called "_kibana_keystore_" and "_logstash_keystore_"
    - Create the keystore and add the proper credentials to both services
6. Build and run the kibana and logstash instance

The "_docker-compose.setup.yml_" file is used to generate certificates and create the keystores.
The "_docker-compose.yml_" file is used to deploy the services.
It uses secrets for the certificates, the keystores and the passwords.

No passwords are stored in plaintext or shown inside the containers.

To see the passwords, the current recommendation would to use `vi` or `nano`,
write down the password to your favorite password manager and delete the file.

There a many ways to build an ELK. I am aware all of this could be siemplified and not all these services would be necessary.

### Notes
#### Elasticsearch Configuration Files
- `elk/elasticsearch/config/elasticsearch.yml`
- `elk/elasticsearch/config/log4j2.properties`

#### Logstash Configuration Files

- Main Configuration
  - `elk/logstash/config/logstash.yml`
  - `elk/logstash/config/pipelines.yml`
- Pipeline Configuration
  - `elk/logstash/pipelines/*`
- Index Templates
  - `elk/logstash/templates/*`
  
#### Kibana Configuration File
- `elk/kibana/config/kibana.yml`

## Known Issues
#### Kibana and Logstash are not able to connect to the Elasticsearch
Verify the file `secrets/pass/passfile.txt` exists and is not empty. 
It is most likely a permission issue, you can adjust the permissions or use `sudo` to build the stack.

#### You have enabled encryption but DISABLED certificate verification
This is a known false positive, for more information view this [issue](https://github.com/elastic/logstash/issues/10352).

```
** WARNING ** Detected UNSAFE options in elasticsearch output configuration!
** WARNING ** You have enabled encryption but DISABLED certificate verification.
** WARNING ** To make sure your data is secure change :ssl_certificate_verification to true
```

## TODOS
- [ ] Add pre-configured templates for logstash
- [ ] Use a secret manager to store the credentials
- [ ] Optimize the way we are building the stack
