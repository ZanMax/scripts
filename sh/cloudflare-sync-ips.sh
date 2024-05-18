#!/bin/bash

# Function to update HAProxy list
update_haproxy() {
    CLOUDFLARE_HAPROXY_LIST_PATH=${1:-/etc/haproxy/CF_ips.lst}

    echo "" > $CLOUDFLARE_HAPROXY_LIST_PATH

    echo "# IPv4 addresses" >> $CLOUDFLARE_HAPROXY_LIST_PATH
    curl -s -L https://www.cloudflare.com/ips-v4 | while read -r line ; do
        echo $line >> $CLOUDFLARE_HAPROXY_LIST_PATH
    done

    echo "" >> $CLOUDFLARE_HAPROXY_LIST_PATH
    echo "# IPv6 addresses" >> $CLOUDFLARE_HAPROXY_LIST_PATH
    curl -s -L https://www.cloudflare.com/ips-v6 | while read -r line ; do
        echo $line >> $CLOUDFLARE_HAPROXY_LIST_PATH
    done

    echo "HAProxy list updated at $CLOUDFLARE_HAPROXY_LIST_PATH"
    echo "Remember to reload your HAProxy configuration to apply changes."
}

# Function to update NGINX configuration
update_nginx() {
    CLOUDFLARE_FILE_PATH=${1:-/etc/nginx/cloudflare}

    echo "#Cloudflare" > $CLOUDFLARE_FILE_PATH
    echo "" >> $CLOUDFLARE_FILE_PATH
    echo "# - IPv4" >> $CLOUDFLARE_FILE_PATH
    curl -s -L https://www.cloudflare.com/ips-v4 | while read -r line ; do
        echo "set_real_ip_from $line;" >> $CLOUDFLARE_FILE_PATH
    done

    echo "" >> $CLOUDFLARE_FILE_PATH
    echo "# - IPv6" >> $CLOUDFLARE_FILE_PATH
    curl -s -L https://www.cloudflare.com/ips-v6 | while read -r line ; do
        echo "set_real_ip_from $line;" >> $CLOUDFLARE_FILE_PATH
    done

    echo "" >> $CLOUDFLARE_FILE_PATH
    echo "real_ip_header CF-Connecting-IP;" >> $CLOUDFLARE_FILE_PATH

    echo "NGINX configuration updated at $CLOUDFLARE_FILE_PATH"
    echo "Testing configuration and reloading NGINX."
    nginx -t && systemctl reload nginx
}

# Main script starts here
echo "Choose the server type you are configuring: [nginx/haproxy]"
read SERVER_TYPE

case $SERVER_TYPE in
    nginx)
        update_nginx
        ;;
    haproxy)
        update_haproxy
        ;;
    *)
        echo "Invalid option. Please choose either 'nginx' or 'haproxy'."
        exit 1
        ;;
esac
