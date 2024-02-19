#!/bin/bash
sudo yum update -y
sudo yum install -y httpd 
sudo amazon-linux-extras install php7.2 lamp-mariadb10.2-php7.2 -y
                            
# Descargar e instalar WordPress
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz -C /var/www/html/
sudo mv /var/www/html/wordpress/* /var/www/html/
sudo rm -rf /var/www/html/wordpress

# Configurar permisos
sudo chown -R apache:apache /var/www/html/
sudo chmod -R 755 /var/www/html/

# Configurar WordPress para usar la base de datos RDS
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i 's/database_name_here/wordpressdb/' /var/www/html/wp-config.php
sudo sed -i 's/username_here/admin/' /var/www/html/wp-config.php
sudo sed -i 's/password_here/password123/' /var/www/html/wp-config.php
sudo sed -i "s/localhost/${aws_db_instance.wordpress_db.endpoint}/" /var/www/html/wp-config.php

# Reiniciar el servicio web
sudo systemctl restart httpd
sudo systemctl enable httpd