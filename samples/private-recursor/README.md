
### Start

    # start powerdns stack
    docker-compose up


### Create DNS stamp for DNSCrypt

    # get DNSCrypt provider public key fingerprint
    docker-compose -f private-recursor.yml exec dnsdist dnsdist -e 'printDNSCryptProviderFingerprint("/var/lib/dnsdist/providerPublic.key")'
    
    # create DNS stamp using python dnsstamps library or visit https://dnscrypt.info/stamps
    dnsstamp.py dnscrypt -s -a 1.2.3.4:8443 -n 2.dnscrypt-cert.example.com -k 2251:468C:FE4C:C39F:9DF3:C2BA:7C95:ED8F:94F6:06BC:7A24:0493:D168:DE9E:7682:E8AD


## Test

    # send DNS queries
    dig @127.0.0.1 -p 1053 example.com
