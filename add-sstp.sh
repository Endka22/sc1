#!/bin/bash
IP=$(wget -qO- ifconfig.co);
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "Usernew: " -e user
		CLIENT_EXISTS=$(grep -i $user /var/lib/premium-script/data-user-sstp | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo "A client with the specified name was already created, please choose another name."
			exit 1
		fi
	done
read -p "Password: " pass
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
cat >> /home/sstp/sstp_account <<EOF
$user * $pass *
EOF
echo -e "\n### $user $exp">>"/var/lib/premium-script/data-user-sstp"
clear
cat <<EOF

================================
SSTP VPN
Server IP     : $IP
Username      : $user
Password      : $pass
Port          : 444
Cert          : http://$IP:81/server.crt
Expired On    : $exp
================================
By Horasss
EOF

