#!/bin/bash
sudo exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
###INSTALL AND START LINUC APACHE MYSQL & PHP DRIVERS####
sudo yum update -y
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
cat /etc/system-release 
sudo yum install -y httpd mariadb-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl start mariadb
#sudo mysql_secure_installation
sudo systemctl enable mariadb
sudo yum install php-mbstring -y
sudo yum install php-xml
sudo systemctl restart httpd
sudo systemctl restart php-fpm
####INSTALL PHPMYADMIN #####
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz
sudo systemctl start mariadb
sudo chkconfig httpd on
sudo chkconfig mariadb on
sudo systemctl status httpd
sudo systemctl status mariadb
#####INSTALL WORDPRESS####
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php
mkdir /var/www/html/
cp -r wordpress/* /var/www/html/
###CREATE WORDPRESS DATABASE AND USER#
export DEBIAN_FRONTEND="noninteractive"
sudo mysql -u root <<EOF
CREATE USER 'wordpress-user'@'localhost' IDENTIFIED BY 'stackinc';
CREATE DATABASE \`stack-wordpress-db3\`;
USE \`stack-wordpress-db3\`;
GRANT ALL PRIVILEGES ON \`stack-wordpress-db3\`.* TO 'wordpress-user'@'localhost';
FLUSH PRIVILEGES;
show tables;
EOF
sudo sed -i 's/database_name_here/stack-wordpress-db3/' /var/www/html/wp-config.php
sudo sed -i 's/username_here/wordpress-user/' /var/www/html/wp-config.php
sudo sed -i 's/password_here/stackinc/' /var/www/html/wp-config.php
## Allow wordpress to use Permalinks###
sudo sed -i '151s/None/All/' /etc/httpd/conf/httpd.conf
###CHANGE OWNERSHIP FOR APACHE AND RESTART SERVICES###
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl restart httpd
sudo systemctl enable httpd && sudo systemctl enable mariadb
sudo systemctl status mariadb
sudo systemctl start mariadb
sudo systemctl status httpd
sudo systemctl start httpd
curl http://169.254.169.254/latest/meta-data/public-ipv4