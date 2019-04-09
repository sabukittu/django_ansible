#!/bin/bash


dja_pro=$(ls /tmp | grep 'django_project_login-logout.zip')
sel=$(getenforce)
pub_ip=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
pro_dir="login_logout"
wsgi_path="/django/login_logout/login_logout/wsgi.py"
set_path="/django/login_logout/login_logout/settings.py"
req_path="/tmp/req.txt"
stat=$(cat ${set_path} | grep  STATIC_ROOT)
wsgi_dir=$(echo $wsgi_path | sed 's/wsgi.py//g')


if [[ ! -z ${dja_pro} ]]; then
  mkdir /django
  cd /django
  unzip /tmp/django_project_login-logout.zip
else
  echo 'Django project in not in /tmp Directory.'
  exit 1
fi

 
if [[ ${sel} == 'Enforcing' ]]; then
	setenforce 0
	sed -i '7 s/enforcing/permissive/gi' /etc/selinux/config
fi

if [[ ! -d /django/${pro_dir}/venv ]]; then
	python3.6 -m venv /django/${pro_dir}/venv
	source /django/${pro_dir}/venv/bin/activate
fi

pip install mod_wsgi
pip install -r ${req_path}

if [[ -z ${stat} ]]; then
	sed -i 's/ALLOWED_HOSTS \= \[]/ALLOWED_HOSTS \= \['"'${pub_ip}'"']/g' ${set_path}
	echo "STATIC_ROOT = os.path.join(BASE_DIR, 'static')" >> ${set_path}
fi

python /django/${pro_dir}/manage.py collectstatic

cat > /etc/httpd/conf.d/django.conf << END

LoadModule wsgi_module /django/${pro_dir}/venv/lib/python3.6/site-packages/mod_wsgi/server/mod_wsgi-py36.cpython-36m-x86_64-linux-gnu.so
	
	<VirtualHost *:80>
    
    	    ServerName ${pub_ip}
        	DocumentRoot "/django/${pro_dir}"
    
        	Alias /static /django/${pro_dir}/static
 	 
 	       	WSGIScriptAlias / ${wsgi_path}
 	       	WSGIDaemonProcess django_process python-path=/django/${pro_dir} python-home=/django/${pro_dir}/venv/
   	     	WSGIProcessGroup django_process
   	
   	     	<Directory /django/${pro_dir}/static>
   	         	Require all granted
   	     	</Directory>
   	     	<Directory ${wsgi_dir}>
   	         	<Files wsgi.py>
            		Require all granted
                </Files>
        	</Directory>
	
	</VirtualHost>

END

chown 48:root -R /django/${pro_dir}
systemctl restart httpd
rm -rf /tmp/*

if [[ $? -eq 0 ]]; then
  echo "Script Execution Success"
fi