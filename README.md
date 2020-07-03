# ELK Stack
## Description
This repository was made to be able to deploy a quick and _secure_ Elasticsearch Stack.

## Notes

This project is under development. 
Additional security measures must be applied.

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

### How the automatic deployment works

1. A temporary service called "_elastic_keystore_" runs to define the "`bootstrap.password`"
2. Generate certificates from the instances defined in "`setup/instances.yml`"
3. Build and run the elasticsearch container
4. Run the script "`setup/gen-password.sh`" (to be renamed)
    - Create the logstash user and role
    - Create the index template "`fortigate`"
    - Use `elasticsearch-setup-passwords` to generate passwords of the built-in users
    - Write the password to the file "`secrets/pass/passfile.txt`"
5. Run two temporary containers called "`kibana_keystore`" and "`logstash_keystore`"
    - Create the keystore 
    - Add credentials to both services
6. Build and run the kibana and logstash instance

The "`docker-compose.setup.yml`" file is used to generate certificates and create the keystores.

The "`docker-compose.yml`" file is used to deploy the services.
It uses secrets for the certificates, the keystores and the passwords.

No passwords are stored in plaintext or shown inside the containers.

The keystore is only obfuscated at this since it is not password
protected.

To see the passwords, the current recommendation would to use `vi` or `nano`,
write down the password to your favorite password manager and delete the file.

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

## Roadmap
#### Deployment

- [ ] Optimize the way we are building the stack

#### Logstash Templates
##### Add pre-configured templates for logstash

- [x] Fortigate 6.X

#### Secret Management

##### Use a secret manager to store the credentials

- [ ] Vault
- [ ] AWS Secrets Manager
