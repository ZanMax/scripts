#!/bin/bash
#
# Nginx - add new host or redirect
#

TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'

echo ''
echo -e $TEXT_YELLOW
echo 'NGINX HOST CONFIGURATION'
echo -e $TEXT_RESET
echo ''

NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'

read -p "Enter domain name : " domain
read -p "Static site or Redirect? ( S or R ): " mode
read -p "Share static files: ( Y or N ): " static

if [[ "$mode" == "R" ]]; then
    read -p "Enter domain to redirect: " redirect
    cat > $NGINX_AVAILABLE_VHOSTS/$domain.conf <<EOF
server {
    listen  80;
    server_name $domain www.$domain;
    return  301 http://$redirect;
}
EOF
else
    if [[ "$static" == "Y" ]]; then
    cat > $NGINX_AVAILABLE_VHOSTS/$domain.conf <<EOF
server {
    listen   80;
    server_name $domain www.$domain;
    root  /var/www/$domain;
    charset  utf-8;
    index index.php index.html index.htm;

    access_log off;
    error_log off;

    location /static/ {
        root /var/www/$domain;
        expires 8d;
    }
}
EOF
    else
            cat > $NGINX_AVAILABLE_VHOSTS/$domain.conf <<EOF
server {
    listen   80;
    server_name $domain www.$domain;
    root  /var/www/$domain;
    charset  utf-8;
    index index.php index.html index.htm;

    access_log off;
    error_log off;
}
EOF
    fi
fi

# Creating symbolic link
ln -s $NGINX_AVAILABLE_VHOSTS/$domain.conf $NGINX_ENABLED_VHOSTS/$domain.conf

# Restart Nginx
service nginx restart

echo -e '\e[32mConfig created for: '$domain'\e[m';