
### Start

    # start powerdns stack
    docker-compose up


## Test

    # send DNS queries
    dig @127.0.0.1 -p 1053 example.com

    # PowerDNS admin interface
    http://localhost:80
    
    # PowerDNS authoritative stats
    http://localhost:8081

    # PowerDNS recursor stats
    http://localhost:8082

    # PowerDNS dnsdist stats
    http://localhost:8083
