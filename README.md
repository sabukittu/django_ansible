## django_ansible

###### Ansible deployment of EC2 instance node with Django demo environment ###### 

##
## Clone the repository to your machine.

## To Execute this playbook you need a EC2 Instance with Ansible, boto, boto3, python3, pip3 installed in it .
## Configure the Ec2 Instance IP to your inventory file(hosts). 

## configure the remote user as 'centos' in ansible.cfg
## configure env var 'ANSIBLE_HOST_KEY_CHECKING=False' 

## You need a aws CLI user access key and secret key in ur home directory '.boto' file
## configure the (ec2_launch/task/main.yml) file with security group, subnet, region, ami, 
## profile_name, ssh_key,

## Copy the 3 files django_script.sh, req.txt, django_project_login-logout.zip to your
## AWS S3 bucket (This is important the script fetch from S3) 
## S3 bucket name should be configured in ansible role(ec2_config) task/main.yml

## You need an IAM role to access S3 and the role need to be specified in YAML file 
## (ec2_launch/task/main.yml) 


## After all the configuration changes you can run the playbook 'ansible_roles/playbook.yml'


#test11


##### END #####
