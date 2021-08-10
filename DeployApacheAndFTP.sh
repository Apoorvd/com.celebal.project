#!/bin/bash
apt-get update

apt-get upgrade

#Install System Firewall
apt-get install ufw -y

systemctl start ufw
#Install FTP server
apt-get install vsftpd -y

#Enable and start vsftpd service

echo "------------- On SystemD ------------- "
systemctl start vsftpd
systemctl enable vsftpd

echo "------------- On SysVInit ------------- "
service vsftpd start
#chkconfig --level 35 vsftpd on


mv /etc/vsftpd.conf /etc/vsftpd.conf_orig
#write a config file here
config="listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO
pasv_enable=Yes
pasv_min_port=10000
pasv_max_port=10100
allow_writeable_chroot=YES
"
echo $config > /etc/vsftpd.conf
ufw allow from any to any port 20,21,10000:10100 proto tcp

chown -cH root /etc/vsftpd.conf
chmod +x /etc/vsftpd.conf
apt install ftp

systemctl restart vsftpd
# if u want new user uncomments the line below
#pswd="ftpuser"
#username="ftpuser"
#pass=$(perl -e 'print crypt($ARGV[0], "password")' $pswd)
#useradd -m -p "$pass" "$username"
#sudo passwd ftpuser
#then enter ur passwrd
#bash -c "echo FTP TESTING > /home/ftpuser/FTP-TEST"




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
