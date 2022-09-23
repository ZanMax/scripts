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