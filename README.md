# Each service's dependencies, initialization steps before execution.

## Metrics
### Dependencies
No dependencies
### Initialization
1. cd into folder where prometheus binary exist.
2. create a config directory in root.
3. copy config file to above created config directory.
### Execution
run prometheus binary with configuration located in above config folder.

## Osmohlr -> OK
### Dependencies
Volume to store its generated database.
### Initialization
1. copy configuration file to "/etc/osmocom".
### Execution
run osmo-hlr binary with configuration located in "/etc/osmocom".
### Notes
1. Need to add 'l' flag to specify the database path of volume attached.

## Osmomsc -> OK
### Dependencies
Volume to store its generated database.
### Initialization
1. copy configuration file to "/etc/osmocom".
### Execution
run osmo-msc binary with configuration located in "/etc/osmocom".
### Notes
1. Need to add 'l' flag to specify the database path of volume attached.

## Smsc -> OK
### Dependencies
1. internal/external mysql service
### Initialization
1. copy configuration files to "/etc/kamailio_smsc".
2. check connectivity with mysql database.
3. create SMSC database, populate tables and grant privileges
4. create run directory "/var/run/kamailio_smsc".
5. remove existing pid file in "/kamailio_smsc.pid".
### Execution
run the service with "kamailio -f /etc/kamailio_smsc/kamailio_smsc.cfg -P /kamailio_smsc.pid -DD -E -e"

## Pcscf -> OK
### Dependencies
1. internal/external mysql service
2. rtpengine service
3. icscf service
4. scscf service
### Initialization
1. system kernel network configuration setting
```bash
sh -c "echo 1 > /proc/sys/net/ipv4/ip_nonlocal_bind"
sh -c "echo 1 > /proc/sys/net/ipv6/ip_nonlocal_bind"
```
2. make configuration folder like "/etc/kamailio_pcscf".
3. copy configuration files to "/etc/kamailio_pcscf".
4. check connectivity with mysql database.
5. create database, populate tables and grant privileges
6. create run directory "/var/run/kamailio_pcscf".
7. remove existing pid file in "/kamailio_pcscf.pid".
8. manually add static route to upf service.
### Execution
run the service with "kamailio -f /etc/kamailio_pcscf/kamailio_pcscf.cfg -P /kamailio_pcscf.pid -DD -E -e"

## Scscf -> OK
### Dependencies
1. internal/external mysql service
2. pyhss service
### Initialization
1. make configuration folder like "/etc/kamailio_scscf".
2. copy configuration files to "/etc/kamailio_scscf".
3. check connectivity with mysql database.
4. create database, populate tables and grant privileges
5. create run directory "/var/run/kamailio_scscf".
6. remove existing pid file in "/kamailio_scscf.pid".
### Execution
run the service with "kamailio -f /etc/kamailio_scscf/kamailio_scscf.cfg -P /kamailio_scscf.pid -DD -E -e"

## Icscf -> OK
### Dependencies
1. internal/external mysql service
2. pyhss service
### Initialization
1. make configuration folder like "/etc/kamailio_icscf".
2. copy configuration files to "/etc/kamailio_icscf".
3. check connectivity with mysql database.
4. create database, populate tables and grant privileges
5. create run directory "/var/run/kamailio_icscf".
6. remove existing pid file in "/kamailio_icscf.pid".
### Execution
run the service with "kamailio -f /etc/kamailio_icscf/kamailio_icscf.cfg -P /kamailio_icscf.pid -DD -E -e"

## Pyhss -> OK
### Dependencies
1. mysql service
### Initialization
1. check connectivity with mysql database.
2. create database, populate tables and grant privileges.
3. copy configuration files to "/pyhss".
4. run flask app in background.
### Execution
run "/pyhss/hss.py"

## Rtpengine -> OK
### Dependencies
No dependencies
### Initialization
1. check if rtpengine module loaded in kernel.
2. populate options of the rtpengine cli command.
3. populate iptable routes.
### Execution
run binary with populated options.

## Pcrf -> OK
### Dependencies
1. Mongo
### Initialization
1. populate require env variables.
2. copy configuration files to "/open5gs/install/etc/open5gs" and "/open5gs/install/etc/freeDiameter".
3. generate tls certificates for freeDiameter.
### Execution
run binary in "/open5gs/install/bin/open5gs-pcrfd"

## Mme -> OK
### Dependencies
1. Hss
2. Sgwc
3. Sgwu
4. Smf
5. Upf
6. Osmomsc
### Initialization
1. populate require env variables.
2. copy configuration files to "/open5gs/install/etc/open5gs" and "/open5gs/install/etc/freeDiameter".
3. generate tls certificates for freeDiameter.
### Execution
run binary in "/open5gs/install/bin/open5gs-mmed"

## Upf -> OK
### Dependencies
1. Smf
2. Adding below snippets in spec of k8s deployment object.
```yaml
securityContext:
    sysctls:
    - name: net.ipv4.ip_forward
      value: "1"
```
### Initialization
1. populate require env variables.
2. create tun interface with scripts (need to put script in image building)
3. copy configuration files to "/open5gs/install/etc/open5gs" and "/open5gs/install/etc/freeDiameter".
### Execution
run binary in "/open5gs/install/bin/open5gs-upfd"

## Smf -> OK
### Dependencies
1. Pcscf
### Initialization
1. populate require env variables.
2. create tun interface with scripts (need to put script in image building)
3. copy configuration files to "/open5gs/install/etc/open5gs" and "/open5gs/install/etc/freeDiameter".
4. copy 4g configuration files to "/open5gs/install/etc/open5gs".
5. generate tls certificates for freeDiameter.
### Execution
run binary in "/open5gs/install/bin/open5gs-smfd"

## Sgwu -> OK
### Dependencies
1. Smf
2. Upf
### Initialization
1. populate require env variables.
2. copy configuration files to "/open5gs/install/etc/open5gs".
### Execution
run binary in "/open5gs/install/bin/open5gs-sgwud"

## Sgwc -> OK
### Dependencies
1. Smf
2. Upf
### Initialization
1. populate require env variables.
2. copy configuration files to "/open5gs/install/etc/open5gs".
### Execution
run binary in "/open5gs/install/bin/open5gs-sgwcd"

## Hss -> OK
### Dependencies
1. internal/external mongo service
### Initialization
1. populate require env variables.
2. copy configuration files to "/open5gs/install/etc/open5gs".
3. generate tls certificates for freeDiameter.
### Execution
run binary in "/open5gs/install/bin/open5gs-hssd"

## Webui -> OK
### Dependencies
1. internal/external mongo service
### Initialization
1. populate require env variables.
### Execution
run "cd webui && npm run dev"
