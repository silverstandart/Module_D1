@echo off
rem ---------------------------------------------------------------------------------------
rem   2_IaaS_destroy.bat / IaaS DevOps Module D1.7 / 2022_04_27 / ANa
rem ---------------------------------------------------------------------------------------

set AND5_origin_location=%cd%

cd processing_folder
terraform destroy

cd /d %AND5_origin_location%

rmdir /S /Q processing_folder

