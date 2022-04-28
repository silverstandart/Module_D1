
## Module_D1.7_IaaS_Report

### 1.	Prerequisites
Before running script **1_IaaS_run.bat** please fill variables in **0_Iaas_variables.bat** and run command 

```sh
yc config set token <your yandex cloud token id>
```

Modify **0_Iaas_variables.bat** accordingly your Yandex cloud environment. What are needed:
* service account name
* cloud id
* folder id

### 2. Create Infrastructure in Yandex Cloud

```sh
1_IaaS_run.bat
```

As a result you can get these machines (as example)
```sh
external_ip_address_vm1 = "51.250.88.39"
external_ip_address_vm2 = "51.250.87.203"
external_ip_address_vm3 = "51.250.82.38"

internal_ip_address_vm1 = "192.168.10.23"
internal_ip_address_vm2 = "192.168.10.9"
internal_ip_address_vm3 = "192.168.10.27"
```

#### 2.1. Create Manager Node
Execute this in machine **external_ip_address_vm1**
```sh
cd processing_folder
ssh.exe -i infodba_key infodba@<external_ip_address_vm1> -o "StrictHostKeyChecking no" 
sudo docker swarm init --advertise-addr <internal_ip_address_vm1>:2377
```
as a result I got this command
```sh
docker swarm join --token SWMTKN-1-3dyyc0jdp557440vmmcsylrjrgqpn4bnj67eqk0grw1nqugv7i-4q1u4ev6j2e9y7c9quic1xj0b 192.168.10.23:2377
```


#### 2.2. Create 2 Worker Nodes
Run result command from **2.1. Create Manager Node** on vm2 and vm3

```sh
rem execute this in machine external_ip_address_vm2
ssh.exe -i infodba_key infodba@<external_ip_address_vm2> -o "StrictHostKeyChecking no"
sudo <docker swarm join command above>
exit

rem execute this in machine external_ip_address_vm3
ssh.exe -i infodba_key infodba@<external_ip_address_vm3> -o "StrictHostKeyChecking no"
sudo <docker swarm join command above>
exit
```

### 3. Deploy Socks Microservices into Swarm Cluster
Execute this in **Manager Node external_ip_address_vm1**

```sh
ssh.exe -i infodba_key infodba@<external_ip_address_vm1> -o "StrictHostKeyChecking no" 
sudo docker node ls
git clone https://github.com/silverstandart/Module_D1.git
cd ./Module_D1/IaaS_socks/
sudo chmod 777 1_run.sh
sed -i -e 's/\r$//' 1_run.sh
./1_run.sh
sudo docker service ls
```sh

rem now site available in http://<external_ip_address_vm1> from any machine


### 4. Uninstallation
```sh
2_IaaS_destroy.bat
```
