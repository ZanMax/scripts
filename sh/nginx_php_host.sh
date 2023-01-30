#!/bin/bash
#
# Nginx - add new PHP host
#

TEXT_RESET='\e[0m'
TEXT_YELLOW='\e[0;33m'
TEXT_RED_B='\e[1;31m'

echo ''
echo -e $TEXT_YELLOW
echo 'NGINX PHP HOST CONFIGURATION'
echo -e $TEXT_RESET
echo ''

NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'

read -p "Enter domain name : " domain

cat > $NGINX_AVAILABLE_VHOSTS/$domain.conf <<EOF
server {
        listen 80;
        root /var/www/$domain;
        index index.php index.html index.htm;
        server_name $domain www.$domain;

        location / {
            try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        }
}
EOF

# Creating symbolic link
ln -s $NGINX_AVAILABLE_VHOSTS/$domain.conf $NGINX_ENABLED_VHOSTS/$domain.conf

# Restart Nginx
service nginx restart

echo -e '\e[32mConfig created for: '$domain'\e[m';