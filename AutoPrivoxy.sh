#!/bin/bash


############################################
# https://github.com/techroy23/AutoPrivoxy #
############################################

echo -e "\n\n\nPLease wait while we setup your IP"
PUBLIC_IPV4=$(curl ifconfig.me)

clear
echo -e "\n\n\n"
read -rp "Please enter the port you want Privoxy to use (between 1000 - 65560): " PORT
if [[ -z $PORT ]]; then
    PORT=8118
fi

echo "Privoxy will run on PORT : $PORT"
read -n1 -rp "Press any key to continue ..."

clear
echo -e "\n\n\n"
apt-get update && apt-get upgrade && apt-get autoclean && apt-get autoremove

clear
echo -e "\n\n\n"
apt-get install -y privoxy

clear
echo -e "\n\n\n"

# Rather than deleting, we mv'ed it instead.
mv /etc/privoxy/config{,.$(date +%d-%b-%Y)}

clear
echo -e "\n\n\n"
cat << EOF >> /etc/privoxy/config
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
filterfile default.filter
logfile logfile
listen-address  0.0.0.0:${PORT}
toggle  1
enable-remote-toggle  0
enable-remote-http-toggle  0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 1
forwarded-connect-retries  1
accept-intercepted-requests 1
allow-cgi-request-crunching 1
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
permit-access 0.0.0.0/0 $PUBLIC_IPV4
EOF

systemctl start privoxy
clear
echo -e "\n\n\n"
systemctl status -l privoxy
ss -4tlnp "( sport = :${PORT} )"
echo -e "\n\n\n"
