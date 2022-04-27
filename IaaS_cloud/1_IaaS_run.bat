@echo off
rem ---------------------------------------------------------------------------------------
rem   1_IaaS_run.bat / IaaS DevOps Module D1.7 / 2022_04_27 / ANa
rem ---------------------------------------------------------------------------------------

call 0_Iaas_variables.bat

rem --------------------------------------------------------------------- Variables
echo AND5_yc_cloud_id              %AND5_yc_cloud_id%
echo AND5_yc_folder_id             %AND5_yc_folder_id%
echo AND5_yc_service_account_name  %AND5_yc_service_account_name%

set AND5_origin_location=%cd%

mkdir processing_folder
cd processing_folder
set AND5_processing_location=%cd%

set AND5_yc_cloud_access_key_file=%cd%\AND5_yc_cloud_access_key_file.json
set AND5_replacement_script=%cd%\replace.vbs

echo AND5_yc_cloud_access_key_file %AND5_yc_cloud_access_key_file%
echo AND5_replacement_script       %AND5_replacement_script%


rem --------------------------------------------------------------------- access into yandex cloud

yc iam key create --folder-id %AND5_yc_folder_id% --service-account-name %AND5_yc_service_account_name% --output %AND5_yc_cloud_access_key_file% 

more %AND5_yc_cloud_access_key_file%


rem --------------------------------------------------------------------- access into virtual machines in cloud
del %AND5_processing_location%\infodba_key
del %AND5_processing_location%\infodba_key.pub

ssh-keygen.exe -t rsa -b 2048 -C infodba -f %AND5_processing_location%\infodba_key -P ""
set /p AND5_yc_vm_rsa=<infodba_key.pub

echo AND5_yc_vm_rsa  %AND5_yc_vm_rsa%
xcopy /Y %AND5_origin_location%\50_infodba_config_template.yml %AND5_processing_location%\infodba_config.yml* 
cscript %AND5_origin_location%\replace.vbs %AND5_processing_location%\infodba_config.yml "@AND5_yc_vm_rsa@" "%AND5_yc_vm_rsa%"


echo ---------------------------------------------------------------------
set str=%AND5_origin_location%\infodba_key.pub 
echo %str% 

set str=%str:\=/% 
echo %str%
echo ---------------------------------------------------------------------
set AND5_yc_cloud_access_key_file=%AND5_yc_cloud_access_key_file:\=/%

set AND5_yc_vm_ssh_user_key_file="%AND5_processing_location%\infodba_key.pub"
set AND5_yc_vm_ssh_user_key_file=%AND5_yc_vm_ssh_user_key_file:\=/%

set AND5_yc_vm_ssh_config_file="%AND5_processing_location%\infodba_config.yml"
set AND5_yc_vm_ssh_config_file=%AND5_yc_vm_ssh_config_file:\=/%

xcopy /Y %AND5_origin_location%\50_terraform_template.tf %AND5_processing_location%\terraform.tf* 
cscript %AND5_origin_location%\replace.vbs %AND5_processing_location%\terraform.tf "@AND5_yc_cloud_id@" %AND5_yc_cloud_id%
cscript %AND5_origin_location%\replace.vbs %AND5_processing_location%\terraform.tf "@AND5_yc_folder_id@" %AND5_yc_folder_id%
cscript %AND5_origin_location%\replace.vbs %AND5_processing_location%\terraform.tf "@AND5_yc_cloud_access_key_file@" %AND5_yc_cloud_access_key_file%
cscript %AND5_origin_location%\replace.vbs %AND5_processing_location%\terraform.tf "@AND5_yc_vm_ssh_user_key_file@" "%AND5_yc_vm_ssh_user_key_file%"
cscript %AND5_origin_location%\replace.vbs %AND5_processing_location%\terraform.tf "@AND5_yc_vm_ssh_config_file@" "%AND5_yc_vm_ssh_config_file%"

terraform init
terraform apply -auto-approve

cd /d %AND5_origin_location%


