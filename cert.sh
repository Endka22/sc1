#!/bin/bash
echo start
sleep 0.5
source /var/lib/premium-script/ipvps.conf
if [[ "$IP" = "" ]]; then
echo "please add domain"
exit 0;
else
domain=$IP
fi
systemctl stop v2ray
systemctl stop v2ray@none
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/v2ray/v2ray.crt --keypath /etc/v2ray/v2ray.key --ecc
systemctl start v2ray
systemctl start v2ray@none
echo Done
sleep 2
clear
neofetch