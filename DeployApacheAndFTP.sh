#!/bin/bash
apt-get update

#Install System Firewall
apt-get install ufw -y
#Install nginx
apt-get install nginx -y

#Install FTP server
apt-get install vsftpd -y

#Enable and start vsftpd service

echo "------------- On SystemD ------------- "
systemctl start vsftpd
systemctl enable vsftpd

echo "------------- On SysVInit ------------- "
#service vsftpd start
#chkconfig --level 35 vsftpd on


mv /etc/vsftpd.conf /etc/vsftpd.conf_orig
#write a config file here
config="listen=NO \n
listen_ipv6=YES \n
anonymous_enable=NO \n
local_enable=YES \n
write_enable=YES  \n
local_umask=022 \n
dirmessage_enable=YES \n
use_localtime=YES \n
xferlog_enable=YES \n
connect_from_port_20=YES \n
chroot_local_user=YES \n
secure_chroot_dir=/var/run/vsftpd/empty \n
pam_service_name=vsftpd \n
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem \n
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key \n
ssl_enable=NO \n
pasv_enable=Yes \n
pasv_min_port=10000 \n
pasv_max_port=10100 \n
allow_writeable_chroot=YES \n
"
echo -e $config > /etc/vsftpd.conf
ufw allow from any to any port 20,21,10000:10100 proto tcp
systemctl restart vsftpd
pswd="ftpuser"
username="ftpuser"
pass=$(perl -e 'print crypt($ARGV[0], "password")' $pswd)
useradd -m -p "$pass" "$username"
#sudo passwd ftpuser
#then enter ur passwrd
bash -c "echo FTP TESTING > /home/ftpuser/FTP-TEST"
apt install ftp



# Apache config

apt install apache2 -y

ufw app list

ufw allow 'Apache'

ufw status

systemctl enable apache2

# Virtual Host

mkdir /var/www/your_domain

chown -R $USER:$USER /var/www/your_domain

chmod -R 755 /var/www/your_domain

sample_webpage="<html> \n
    <head> \n
        <title>Welcome to Your_domain!</title> \n
    </head> \n
    <body> \n
        <h1>Success!  The your_domain virtual host is working!</h1> \n
    </body> \n
</html>"

domain_conf="<VirtualHost *:80> \n
    ServerAdmin webmaster@localhost \n
    ServerName your_domain \n
    ServerAlias your_domain \n
    DocumentRoot /var/www/your_domain \n
    ErrorLog ${APACHE_LOG_DIR}/error.log \n
    CustomLog ${APACHE_LOG_DIR}/access.log combined \n
</VirtualHost>"

echo  $sample_webpage >  /var/www/your_domain/index.html
echo  $domain_conf > /etc/apache2/sites-available/your_domain.conf

a2ensite your_domain.conf

a2dissite 000-default.conf

apache2ctl configtest

systemctl restart apache2
