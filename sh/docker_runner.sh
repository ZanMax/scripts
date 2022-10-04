#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

clear

# CONFIGS

# docker data folder
DATA_FOLDER="/mnt/data/docker_data/"

# temp or perm
STATE="perm"

# END CONFIGS

banner()
{
  echo "+------------------------------------------+"
  printf "| %-40s |\n" "`date`"
  echo "|                                          |"
  printf "|`tput bold` %-40s `tput sgr0`|\n" "$@"
  echo "+------------------------------------------+"
}

banner "Docker Runner v0.2"
printf "\n"

PS3='Select service: '

options=("MySQL" "Postgres" "Mongo" "Redis" "RabbitMQ" "Memcached" "PRUNE" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "MySQL")
            printf "\n"
            echo -e "${GREEN}-> Starting MySQL ... ${NC}"
            echo -e "${GREEN}Port:${NC} 3306"
            echo -e "${GREEN}User:${NC} ${YELLOW}root${NC}"
            echo -e "${GREEN}Password:${NC} ${RED}docker${NC}"
            printf "\n"
            if [ $STATE == "temp" ]
            then
                sudo docker run --rm -d -p 3306:3306 --name=mysql -v ${DATA_FOLDER}mysql_data:/var/lib/mysql --env="MYSQL_ROOT_PASSWORD=docker" mysql mysqld --default-authentication-plugin=mysql_native_password
            else
                sudo docker run -d --restart unless-stopped -p 3306:3306 --name=mysql -v ${DATA_FOLDER}mysql_data:/var/lib/mysql --env="MYSQL_ROOT_PASSWORD=docker" mysql mysqld --default-authentication-plugin=mysql_native_password
            fi
            printf "\n"
            echo -e "${YELLOW}"
            docker ps -f "name=mysql"
            echo -e "${NC}"
            break
            ;;
        "Postgres")
            printf "\n"
            echo -e "${GREEN}-> Starting Postgres ... ${NC}"
            echo -e "${GREEN}Port:${NC} 5432"
            echo -e "${GREEN}User:${NC} ${YELLOW}postgres${NC}"
            echo -e "${GREEN}Password:${NC} ${RED}docker${NC}"
            printf "\n"
            if [ $STATE == "temp" ]
            then
                sudo docker run -d --rm --name postgres -e POSTGRES_PASSWORD=docker -p 5432:5432 -v ${DATA_FOLDER}postgres_data:/var/lib/postgresql/data postgres
            else
                sudo docker run -d --restart unless-stopped --name postgres -e POSTGRES_PASSWORD=docker -p 5432:5432 -v ${DATA_FOLDER}postgres_data:/var/lib/postgresql/data postgres
            fi
            printf "\n"
            echo -e "${YELLOW}"
            docker ps -f "name=postgres"
            echo -e "${NC}"
            break
            ;;
        "Mongo")
            printf "\n"
            echo -e "${GREEN}-> Starting Mongo ... ${NC}"
            echo -e "${GREEN}Port:${NC} 27017"
            printf "\n"
            if [ $STATE == "temp" ]
            then
                sudo docker run --rm -d -p 27017:27017 --name mongo -v ${DATA_FOLDER}mongo_data:/data/db mongo
            else
                sudo docker run -d --restart unless-stopped -p 27017:27017 --name mongo -v ${DATA_FOLDER}mongo_data:/data/db mongo
            fi
            printf "\n"
            echo -e "${YELLOW}"
            docker ps -f "name=mongo"
            echo -e "${NC}"
            break
            ;;
        "Redis")
            printf "\n"
            echo -e "${GREEN}-> Starting Redis ... ${NC}"
            echo -e "${GREEN}Port:${NC} 6379"
            printf "\n"
            if [ $STATE == "temp" ]
            then
                sudo docker run --rm -d -p 6379:6379 --name redis --user 1000:50 -v ${DATA_FOLDER}redis_data:/data --entrypoint redis-server redis
            else
                sudo docker run -d --restart unless-stopped -p 6379:6379 --name redis --user 1000:50 -v ${DATA_FOLDER}redis_data:/data --entrypoint redis-server redis
            fi
            printf "\n"
            echo -e "${YELLOW}"
            docker ps -f "name=redis"
            echo -e "${NC}"
            break
            ;;
        "RabbitMQ")
            printf "\n"
            echo -e "${GREEN}-> Starting RabbitMQ ... ${NC}"
            echo -e "${GREEN}Port:${NC} 5672"
            echo -e "${GREEN}Management:${NC} http://localhost:15672/"
            echo -e "User: guest"
            echo -e "Password: guest"
            printf "\n"
            if [ $STATE == "temp" ]
            then
                sudo docker run --rm -d --name rabbitmq -p 5672:5672 -p 5673:5673 -p 15672:15672 -v ${DATA_FOLDER}rabbitmq_data:/var/lib/rabbitmq --hostname dev-rabbit rabbitmq:3-management
            else
                sudo docker run -d --restart unless-stopped --name rabbitmq -p 5672:5672 -p 5673:5673 -p 15672:15672 -v ${DATA_FOLDER}rabbitmq_data:/var/lib/rabbitmq --hostname dev-rabbit rabbitmq:3-management
            fi
            printf "\n"
            echo -e "${YELLOW}"
            docker ps -f "name=rabbitmq"
            echo -e "${NC}"
            break
            ;;
        "Memcached")
			printf "\n"
			echo -e "${GREEN}-> Starting Memcached ... ${NC}"
			echo -e "${GREEN}Port:${NC} 11211"
            printf "\n"
            if [ $STATE == "temp" ]
            then
                sudo docker run --rm -p 11211:11211 --name memcache -d memcached
            else
                sudo docker run -d --restart unless-stopped -p 11211:11211 --name memcache memcached
            fi
            printf "\n"
            echo -e "${YELLOW}"
            docker ps -f "name=memcache"
            echo -e "${NC}"
            break
            ;;
        "PRUNE")
            printf "\n"
            echo -e "${GREEN}-> Starting System PRUNE ... ${NC}"
            printf "\n"
            sudo docker system prune -f -a
            printf "\n"
            break
            ;;
        "Quit")
            break
            ;;
        *) echo -e "${RED}Invalid option $REPLY${NC}";;
    esac
done
