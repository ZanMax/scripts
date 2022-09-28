## Some short docs

### Signal Proxy
```bash
sudo apt update && sudo apt install docker docker-compose git
git clone https://github.com/signalapp/Signal-TLS-Proxy.git
cd Signal-TLS-Proxy
sudo ./init-certificate.sh
sudo docker-compose up --detach
```

Share link: https://signal.tube/#<your_domain_name>


### Telegram Proxy
```bash
docker run -d -p443:443 --name=mtproto-proxy --restart=always -v proxy-config:/data telegrammessenger/proxy:latest
docker logs mtproto-proxy
```
Copy secret
```bash
Secret 1: 00baadf00d15abad1deaa515baadcafe
```

Register proxy

https://t.me/MTProxybot

### Snowflake Proxy / Tor proxy
```bash
wget https://gitlab.torproject.org/tpo/anti-censorship/docker-snowflake-proxy/raw/main/docker-compose.yml
```

```bash
docker-compose up -d snowflake-proxy
```

### Setting up a Tor bridge
```bash
mkdir bridge
cd bridge
wget https://gitlab.torproject.org/tpo/anti-censorship/docker-obfs4-bridge/-/raw/main/docker-compose.yml
```

Edit bridge/.env 
```bash
# Set required variables
OR_PORT=3344
PT_PORT=3355
EMAIL=your@email.com

# If you want, you could change the nickname of your bridge
#NICKNAME=DockerObfs4Bridge

# Configure the bridge so it will not be distributed by bridgedb:
OBFS4_ENABLE_ADDITIONAL_VARIABLES=1
OBFS4V_BridgeDistribution=none
```

Start the bridge:
```bash
docker compose up -d
```