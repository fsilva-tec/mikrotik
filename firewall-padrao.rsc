## ADDRESS-LIST
/ip firewall address-list
add address=77.111.244.0/24 comment="******* VPN Opera - IP *******" list=\
    "VPN Opera"
add address=77.111.245.0/24 list="VPN Opera"
add address=77.111.246.0/24 list="VPN Opera"
add address=1.1.1.1 comment="******* WHITE LIST *******" list=White-List
add address=8.8.8.8 list=White-List
add address=8.8.4.4 list=White-List
add address=1.0.0.1 list=White-List
## FILTER
/ip firewall filter
add action=accept chain=input comment="******* CONEXOES ATIVAS *******" \
    connection-state=established,related
add action=drop chain=input comment="******* CONEXOES INVALIDAS *******" \
    connection-state=invalid
add action=accept chain=input comment="******* PING - ICMP *******" \
    icmp-options=0:0 limit=1,10:packet protocol=icmp
add action=accept chain=input icmp-options=8:0 protocol=icmp
add action=accept chain=input icmp-options=11:0 protocol=icmp
add action=accept chain=input icmp-options=3:0 protocol=icmp
add action=accept chain=input icmp-options=3:1 protocol=icmp
add action=accept chain=input icmp-options=3:4 protocol=icmp
add action=accept chain=input icmp-options=12:0 protocol=icmp
add action=drop chain=input protocol=icmp
add action=drop chain=input comment="******* DDoS *******" dst-port=53 \
    in-interface-list=WAN protocol=tcp
add action=drop chain=input dst-port=53 in-interface-list=WAN \
    protocol=udp
add action=add-src-to-address-list address-list=Blacklist-SYN \
    address-list-timeout=4w2d chain=input comment="******* SYN FLOOD *******" \
    connection-limit=400,32 protocol=tcp
add action=tarpit chain=input connection-limit=3,32 protocol=tcp \
    src-address-list=Blacklist-SYN
add action=jump chain=forward connection-state=new jump-target=SYN-Protect \
    protocol=tcp tcp-flags=syn
add action=accept chain=SYN-Protect connection-state=new limit=400,5 \
    protocol=tcp tcp-flags=syn
add action=drop chain=SYN-Protect connection-state=new protocol=tcp \
    tcp-flags=syn
add action=add-src-to-address-list address-list=Blacklist-PortScan \
    address-list-timeout=4w2d chain=input comment="******* PORTSCAN *******" \
    in-interface-list=WAN psd=21,3s,3,1
add action=add-src-to-address-list address-list=Blacklist-SSH \
    address-list-timeout=4w2d chain=input comment=\
    "******* DROP SSH BRUTE FORCES *******" connection-state=new dst-port=22 \
    protocol=tcp src-address-list=SSH-Estagio3
add action=add-src-to-address-list address-list=SSH-Estagio3 \
    address-list-timeout=1m chain=input connection-state=new dst-port=22 \
    protocol=tcp src-address-list=SSH-Estagio2
add action=add-src-to-address-list address-list=SSH-Estagio2 \
    address-list-timeout=1m chain=input connection-state=new dst-port=22 \
    protocol=tcp src-address-list=SSH-Estagio1
add action=add-src-to-address-list address-list=SSH-Estagio1 \
    address-list-timeout=1m chain=input connection-state=new dst-port=22 \
    protocol=tcp
add action=reject chain=forward comment="******* VPN Opera *******" log=yes \
    log-prefix=Opera protocol=tcp reject-with=icmp-admin-prohibited \
    src-address-list="VPN Opera"
add action=add-src-to-address-list address-list=Blacklist-SPAM \
    address-list-timeout=3h chain=forward comment=\
    "******* BLOCK SPAMMERS *******" connection-limit=30,32 dst-port=25,587 \
    limit=30/1m,0:packet protocol=tcp
add action=drop chain=forward dst-port=25,587 protocol=tcp src-address-list=\
    Blacklist-SPAM
add action=drop chain=forward dst-address=0.0.0.0/0 dst-port=25,587 protocol=\
    tcp src-address=0.0.0.0/0
add action=drop chain=forward comment="******* BOGON IP *******" src-address=\
    0.0.0.0/8
add action=drop chain=forward dst-address=0.0.0.0/8
add action=drop chain=forward src-address=127.0.0.0/8
add action=drop chain=forward dst-address=127.0.0.0/8
add action=drop chain=forward src-address=224.0.0.0/3
add action=drop chain=forward dst-address=224.0.0.0/3
add action=accept chain=input comment="******* WWW-SSL CERTIFICATE *******" \
    disabled=yes dst-port=443 in-interface-list=WAN protocol=tcp
add action=accept chain=input disabled=yes dst-port=80 in-interface-list=WAN \
    protocol=tcp
## RAW
/ip firewall raw
add action=drop chain=prerouting comment="******* PortScan *******\"" log=yes \
    log-prefix=ATQ-PortScan src-address-list=Blacklist-PortScan
add action=drop chain=prerouting comment="******* SSH BRUTE FORCES *******" \
    protocol=tcp src-address-list=Blacklist-SSH
add action=drop chain=prerouting comment="******* PROTECION HOSTs *******" \
    protocol=udp src-port=19,25,1900,11211
add action=drop chain=prerouting protocol=tcp src-port=19,25,1900,11211
add action=drop chain=prerouting dst-port=19,25,1900,11211 protocol=udp
add action=drop chain=prerouting dst-port=19,25,1900,11211 protocol=tcp