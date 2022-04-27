rem Before running script 1_IaaS_run.bat please fill variables in 0_Iaas_variables.bat and run command 
yc config set token <your yandex cloud token id>

rem modify 0_Iaas_variables.bat accordingly your Yandex cloud environment. What are needed:
service account name
cloud id
folder id

rem To create Infrastructure in Yandex Cloud run 
1_IaaS_run.bat

rem as a result you can get these machines
external_ip_address_vm1 = "51.250.83.240"
external_ip_address_vm2 = "51.250.85.111"
external_ip_address_vm3 = "51.250.81.187"
internal_ip_address_vm1 = "192.168.10.26"
internal_ip_address_vm2 = "192.168.10.22"
internal_ip_address_vm3 = "192.168.10.3"

rem execute this in machine external_ip_address_vm1
ssh.exe -i F:/DEV_HOME/Terraform_Projects/D1_7/processing_folder/infodba_key infodba@51.250.83.240 -o "StrictHostKeyChecking no" 
sudo docker swarm init --advertise-addr 192.168.10.26:2377

rem execute this in machine external_ip_address_vm2
ssh.exe -i F:/DEV_HOME/Terraform_Projects/D1_7/processing_folder/infodba_key infodba@51.250.85.111 -o "StrictHostKeyChecking no"
sudo docker swarm join --token SWMTKN-1-0a71wqp1aez636htba8gcvealek1klqzy829tqxjm2590wsreo-57yrbyxe8hejq9s7qc7ki0q31 192.168.10.26:2377
exit

rem execute this in machine external_ip_address_vm3
ssh.exe -i F:/DEV_HOME/Terraform_Projects/D1_7/processing_folder/infodba_key infodba@51.250.81.187 -o "StrictHostKeyChecking no"
sudo docker swarm join --token SWMTKN-1-0a71wqp1aez636htba8gcvealek1klqzy829tqxjm2590wsreo-57yrbyxe8hejq9s7qc7ki0q31 192.168.10.26:2377
exit

rem execute this in machine external_ip_address_vm1
ssh.exe -i F:/DEV_HOME/Terraform_Projects/D1_7/processing_folder/infodba_key infodba@51.250.83.240 -o "StrictHostKeyChecking no" 
sudo docker node ls
sudo chmod 777 1_run.sh
sed -i -e 's/\r$//' 1_run.sh
./1_run.sh
sudo docker service ls

rem now site available in http://51.250.83.240 from any machine


rem uninstallation
2_IaaS_destroy.bat