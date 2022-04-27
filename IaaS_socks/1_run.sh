#!/bin/sh
# ---------------------------------------------------------------------------------------
#   Test Microservices Image with Docker / 2022_04_22 / ANa
# ---------------------------------------------------------------------------------------

echo ------------------------------------------------------ Create temp folder microservices
mkdir ./microservices_root
chmod 777 ./microservices_root
cd microservices_root


echo "\n\n"
echo ------------------------------------------------------ Create docker-compose.yml
cat << EOF > ./docker-compose.yml
# ----------------------------- docker-compose.yml START --------------------
version: "3"

services:
  front-end: # -------------------------------------------- worker 3
    image: weaveworksdemos/front-end:0.3.12
    hostname: front-end
    restart: always
    cap_drop:
      - all
#    read_only: true
#    deploy:
#      placement:
#        constraints: [node.role == manager]
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=FRONT_END]
      placement:
        constraints: [node.role == worker]

  edge-router: # -------------------------------------------- worker 3
    image: weaveworksdemos/edge-router:0.1.1
    ports:
      - '80:80'
      - '8080:8080'
    cap_drop:
      - all
    cap_add:
      - NET_BIND_SERVICE
      - CHOWN
      - SETGID
      - SETUID
      - DAC_OVERRIDE
#    read_only: true
    tmpfs:
      - /var/run:rw,noexec,nosuid
    hostname: edge-router
    restart: always
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=FRONT_END]
      placement:
        constraints: [node.role == worker]

  catalogue: # -------------------------------------------- worker 3
    image: weaveworksdemos/catalogue:0.3.5
    hostname: catalogue
    restart: always
    cap_drop:
      - all
    cap_add:
      - NET_BIND_SERVICE
#    read_only: true
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=FRONT_END]
      placement:
        constraints: [node.role == worker]

  catalogue-db: # -------------------------------------------- manager
    image: weaveworksdemos/catalogue-db:0.3.0
    hostname: catalogue-db
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_ALLOW_EMPTY_PASSWORD=true
      - MYSQL_DATABASE=socksdb
    deploy:
      placement:
        constraints: [node.role == manager]
        
  carts: # -------------------------------------------- worker 3
    image: weaveworksdemos/carts:0.4.8
    hostname: carts
    restart: always
    cap_drop:
      - all
    cap_add:
      - NET_BIND_SERVICE
#    read_only: true
    tmpfs:
      - /tmp:rw,noexec,nosuid
    environment:
      - JAVA_OPTS=-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=FRONT_END]
      placement:
        constraints: [node.role == worker]
      
  carts-db: # -------------------------------------------- manager
    image: mongo:3.4
    hostname: carts-db
    restart: always
    cap_drop:
      - all
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
#    read_only: true
    tmpfs:
      - /tmp:rw,noexec,nosuid
    deploy:
      placement:
        constraints: [node.role == manager]
        
  orders: # -------------------------------------------- worker 3
    image: weaveworksdemos/orders:0.4.7
    hostname: orders
    restart: always
    cap_drop:
      - all
    cap_add:
      - NET_BIND_SERVICE
#    read_only: true
    tmpfs:
      - /tmp:rw,noexec,nosuid
    environment:
      - JAVA_OPTS=-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=FRONT_END]
      placement:
        constraints: [node.role == worker]

  orders-db: # -------------------------------------------- manager
    image: mongo:3.4
    hostname: orders-db
    restart: always
    cap_drop:
      - all
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
#    read_only: true
    tmpfs:
      - /tmp:rw,noexec,nosuid
    deploy:
      placement:
        constraints: [node.role == manager]

  shipping: # -------------------------------------------- worker 3
    image: weaveworksdemos/shipping:0.4.8
    hostname: shipping
    restart: always
    cap_drop:
      - all
    cap_add:
      - NET_BIND_SERVICE
#    read_only: true
    tmpfs:
      - /tmp:rw,noexec,nosuid
    environment:
      - JAVA_OPTS=-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=FRONT_END]
      placement:
        constraints: [node.role == worker]

  queue-master: # -------------------------------------------- worker 3
    image: weaveworksdemos/queue-master:0.3.1
    hostname: queue-master
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    restart: always
    cap_drop:
      - all
    cap_add:
      - NET_BIND_SERVICE
#    read_only: true
    tmpfs:
      - /tmp:rw,noexec,nosuid
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=FRONT_END]
      placement:
        constraints: [node.role == worker]

  rabbitmq: # -------------------------------------------- worker 3
    image: rabbitmq:3.6.8
    hostname: rabbitmq
    restart: always
    cap_drop:
      - all
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
      - DAC_OVERRIDE
#    read_only: true
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=FRONT_END]
      placement:
        constraints: [node.role == worker]

  payment: # -------------------------------------------- worker 3
    image: weaveworksdemos/payment:0.4.3
    hostname: payment
    restart: always
    cap_drop:
      - all
    cap_add:
      - NET_BIND_SERVICE
#    read_only: true
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=FRONT_END]
      placement:
        constraints: [node.role == worker]

  user: # -------------------------------------------- worker 3
    image: weaveworksdemos/user:0.4.4
    hostname: user
    restart: always
    cap_drop:
      - all
    cap_add:
      - NET_BIND_SERVICE
#    read_only: true
    environment:
      - MONGO_HOST=user-db:27017
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=FRONT_END]
      placement:
        constraints: [node.role == worker]

  user-db: # -------------------------------------------- manager
    image: weaveworksdemos/user-db:0.4.0
    hostname: user-db
    restart: always
    cap_drop:
      - all
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
#    read_only: true
    tmpfs:
      - /tmp:rw,noexec,nosuid
    deploy:
      placement:
        constraints: [node.role == manager]
        
  user-sim: # -------------------------------------------- worker 3
    image: weaveworksdemos/load-test:0.1.1
    cap_drop:
      - all
#    read_only: true
    hostname: user-simulator
    command: "-d 60 -r 200 -c 2 -h edge-router"
    deploy:
      mode: replicated
      replicas: 2
      labels: [APP=FRONT_END]
      placement:
        constraints: [node.role == worker]

# ----------------------------- docker-compose.yml END  --------------------
EOF
cat ./docker-compose.yml


echo ------------------------------------------------------ Create Image and Run
sudo docker stack deploy --compose-file docker-compose.yml andrey
#sudo docker-compose deploy --compose-file docker-compose.yml
#sudo docker-compose build --no-cache
sleep 5
echo "\n"
sudo docker service ls
echo "\n"
#sudo docker service ps andrey_carts-db
#sudo docker service logs andrey_carts-db

