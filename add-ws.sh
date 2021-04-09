#!/bin/bash 
source /var/lib/premium-script/ipvps.conf
if [[ "$IP" = "" ]]; then
echo "please add domain"
exit 0;
else
domain=$IP
fi
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "User: " -e user
		CLIENT_EXISTS=$(grep -i $user /etc/v2ray/akun.conf | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#tls$/a\# BEGIN_SSWS '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"2"',"email": "'""$user""'"\
# END_SSWS '"$user $exp"'' /etc/v2ray/config.json
sed -i '/#none$/a\# BEGIN_SSWS '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"2"',"email": "'""$user""'"\
# END_SSWS '"$user $exp"'' /etc/v2ray/none.json
vmess_json1=`cat <<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "8443",
      "id": "${uuid}",
      "aid": "2",
      "net": "ws",
      "path": "/vpnstores",
      "type": "none",
      "host": "",
      "tls": "tls"
}
EOF`
vmess_json2=`cat <<EOF
      {
      "v": "2",
      "ps": "${user}",
      "add": "${domain}",
      "port": "80",
      "id": "${uuid}",
      "aid": "2",
      "net": "ws",
      "path": "/vpnstores",
      "type": "none",
      "host": "",
      "tls": "none"
}
EOF`
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmesslink1="vmess://$vmess_base641"
vmesslink2="vmess://$vmess_base642"
tgl=$(echo "$exp" | cut -d- -f3)
bln=$(echo "$exp" | cut -d- -f2)
cat << EOF >> /etc/crontab
# BEGIN_SSWS $user $exp
*/1 0 $tgl $bln * root printf "$user" | xp-ws
# END_SSWS $user $exp
EOF
echo -e "\n### $user $exp
${vmesslink}">> /etc/v2ray/akun.conf
systemctl restart v2ray
systemctl restart v2ray@none
service cron restart
clear
echo -e ""
echo -e "==========-V2RAY/VMESS-=========="
echo -e "Remarks        : ${user}"
echo -e "Domain         : ${domain}"
echo -e "port TLS       : 8443"
echo -e "port none TLS  : 80"
echo -e "id             : ${uuid}"
echo -e "alterId        : 2"
echo -e "Security       : auto"
echo -e "network        : ws"
echo -e "path           : /kangcoli",
echo -e "================================="
echo -e "link TLS       : ${vmesslink1}"
echo -e "================================="
echo -e "link none TLS  : ${vmesslink2}"
echo -e "================================="
echo -e "Expired On     : $exp"
echo -e "AutoScriptVPS By  Kangcoli"
