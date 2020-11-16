
### Create Certificates

    # Create certificate directories
    mkdir -p ca-certs
    mkdir -p master/certs
    mkdir -p slave/certs

    # Generate a private key for root ca
    openssl genrsa -des3 -out ca-certs/root.key 2048
    
    # Set permissions of private key file
    chmod 0600 ca-certs/root.key

    # Create a self-signed certificate
    openssl req -new -key ca-certs/root.key -days 3650 -subj "/CN=PostgreSQL_Server_CA_Certificate" -out ca-certs/root.crt -x509
    
    # Check certificate information
    openssl x509 -in ca-certs/root.crt -noout -issuer -subject -dates


    # Create the private key server.key and remove the passphrase
    openssl genrsa -passout pass:abcd -des3 -out master/certs/server.key 1024
    openssl rsa -passin pass:abcd -in master/certs/server.key -out master/certs/server.key

    # Set permissions of private key file
    chmod 0600 master/certs/server.key

    # Create the certificate server.crt
    openssl req -new -key master/certs/server.key -subj "/CN=clu01.auth-db.internal" -out master/certs/server.csr

    # Sign it using the root certificate
    openssl x509 -req -in master/certs/server.csr -CA ca-certs/root.crt -CAkey ca-certs/root.key -out master/certs/server.crt -CAcreateserial    
    
    # Check certificate information
    openssl x509 -in master/certs/server.crt -noout -issuer -subject -dates


    # Create the private key replicator.key and remove the passphrase
    openssl genrsa -passout pass:abcd -des3 -out slave/certs/replicator.key 1024
    openssl rsa -passin pass:abcd -in slave/certs/replicator.key -out slave/certs/replicator.key

    # Set permissions of private key file
    chmod 0600 slave/certs/replicator.key

    # Create the certificate replicator.crt
    openssl req -new -key slave/certs/replicator.key -subj "/CN=replicator" -out slave/certs/replicator.csr

    # Sign it using the root certificate
    openssl x509 -req -in slave/certs/replicator.csr -CA ca-certs/root.crt -CAkey ca-certs/root.key -out slave/certs/replicator.crt -CAcreateserial
    
    # Check certificate information
    openssl x509 -in slave/certs/replicator.crt -noout -issuer -subject -dates


    # Set certificate permissions
    sudo chown -R 70:70 ca-certs
    sudo chown -R 70:70 master/certs
    sudo chown -R 70:70 slave/certs


### Start

The domain clu01.auth-db.internal should point to the host that is running your master database. In this example everything is running on localhost.
Therefore, it has to be set to an ip-address the slave database container is able to connect to, for me it is the local ip-address that the router assigns to the used host.

After configuring the ip-address for the domain clu01.auth-db.internal in slave.yml you are ready to go. 

    # Start master and wait until it is up and running
    docker-compose -f master.yml up
    
    # Start slave
    docker-compose -f slave.yml up


## Test

    ## create new zone: example.sys
    curl -v -X POST -H 'X-API-Key: api-secret-authoritative' -H 'Content-Type: application/json' -d '{"name": "example.sys.", "kind": "native", "rrsets": [ {"name": "example.sys.", "type": "SOA", "ttl": 86400, "changetype": "REPLACE", "records": [ {"content": "a.nic.sys. hostmaster.nic.sys. 0 10800 3600 604800 3600", "disabled": false } ] } ], "nameservers": ["a.nic.sys.", "b.nic.sys."]}' http://127.0.0.1:8081/api/v1/servers/localhost/zones
    curl -v -X PATCH -H 'X-API-Key: api-secret-authoritative' -H 'Content-Type: application/json' -d '{"rrsets": [ {"name": "example.sys.", "type": "A", "ttl": 86400, "changetype": "REPLACE", "records": [ {"content": "127.0.0.1", "disabled": false } ] } ] }' http://127.0.0.1:8081/api/v1/servers/localhost/zones/example.sys.
    
    # use master
    dig @127.0.0.1 -p 1053 example.sys.
    
    # use slave
    dig @127.0.0.1 -p 2053 example.sys.
