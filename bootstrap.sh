#!/usr/bin/env bash

echo 'be advised, this runs only on Linux or Mac, not on windows, due to NFS sharing!'

Update () {
    echo "-- Update packages --"
    sudo apt-get update
    sudo apt-get -y upgrade 
}
Update
sudo usermod -a -G www-data ubuntu
sudo locale-gen de_DE.UTF-8
sudo locale-gen de_CH.UTF-8
sudo locale-gen fr_FR.UTF-8
sudo locale-gen fr_CH.UTF-8
sudo locale-gen it_IT.UTF-8
sudo locale-gen it_CH.UTF-8
sudo locale-gen en_US.UTF-8
sudo locale-gen en_UK.UTF-8
sudo update-locale LANG=de_DE.UTF-8 LC_MESSAGES=POSIX

echo "-- Prepare configuration for MySQL --"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password 123"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 123"

echo "-- Install tools and helpers --"
sudo apt-get install -y language-pack-en-base python-software-properties vim htop curl git npm xclip

echo "-- Install PPA's --"
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:chris-lea/redis-server
Update

echo "-- Install NodeJS --"
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

echo "-- Install packages --"
sudo apt-get install -y apache2 mysql-server git-core nodejs rabbitmq-server redis-server golang-go
#sudo touch /var/run/mysqld/mysql.sock
#sudo chown -R mysql:adm /var/run/mysqld
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y sendmail
cat << EOF | sudo tee -a /etc/hosts
127.0.0.1       localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost   ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
127.0.1.1       localhost       localhost.localdomain   ubuntu-xenial
EOF
wget https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64
sudo mkdir /opt/mailhog && sudo mv MailHog_linux_amd64 /opt/mailhog/mailhog && sudo chmod +x /opt/mailhog/mailhog
sudo cp /vagrant/mailhog.sh /etc/init.d/mailhog && sudo chmod +x /etc/init.d/mailhog && sudo update-rc.d mailhog defaults
/opt/mailhog/mailhog bcrypt 123 | sudo tee -a /opt/mailhog/auth && sudo sed -i -e 's/^/root:/' /opt/mailhog/auth
sudo apt-get install -y php7.0-common php7.0-json php7.0-cli libapache2-mod-php7.0 php7.0 php7.0-mysql php7.0-fpm php7.0-curl php7.0-gd php7.0-mcrypt php7.0-mbstring php7.0-bcmath php7.0-zip php7.0-xml php7.0-intl php-xdebug
Update

echo "-- Configure PHP &Apache --"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini
sudo a2enmod rewrite
sudo service apache2 restart


echo "-- Creating virtual hosts --"
#sudo ln -fs /vagrant/public/ /var/www/app
sudo chown -R ubuntu:ubuntu /var/log/apache2
sudo chown ubuntu:ubuntu /var/log/php7.0-fpm.log
#sudo chown syslog:adm /var/log/mail.log
#sudo chown -R mysql:adm /var/log/mysql
#sudo chown -R rabbitmq:rabbitmq /var/log/rabbitmq
#sudo chown -R redis:redis /var/log/redis
mkdir /var/www/app
mkdir /var/www/app/web
cat << EOF | sudo tee -a /etc/apache2/sites-available/default.conf
<Directory "/var/www/">
    AllowOverride All
</Directory>

<VirtualHost *:80>
    DocumentRoot /var/www/app/web
    ServerName app.dev
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot /var/www/phpmyadmin
    ServerName phpmyadmin.dev
</VirtualHost>
EOF
sudo a2ensite default.conf

cat << EOF | sudo tee -a /etc/php/7.0/apache2/conf.d/99-custom.ini
max_execution_time = 300
max_input_time = 300
memory_limit = 512M
upload_max_filesize = 30M
post_max_size = 20M
xdebug.max_nesting_level = 512
EOF

#sudo chown ubuntu:ubuntu /etc/mysql/mysql.conf.d/mysqld.cnf
#sudo echo "default-character-set=utf8" >> /etc/mysql/mysql.conf.d/mysqld.cnf
#sudo echo "skip-character-set-client-handshake" >> /etc/mysql/mysql.conf.d/mysqld.cnf
#sudo chown root:root /etc/mysql/mysql.conf.d/mysqld.cnf

sed -i -e 's/user = www-data/user = ubuntu/g' /etc/php/7.0/fpm/pool.d/www.conf
sed -i -e 's/group = www-data/group = ubuntu/g' /etc/php/7.0/fpm/pool.d/www.conf
sed -i -e 's/listen.owner = www-data/listen.owner = ubuntu/g' /etc/php/7.0/fpm/pool.d/www.conf
sed -i -e 's/listen.group = www-data/listen.group = ubuntu/g' /etc/php/7.0/fpm/pool.d/www.conf
sed -i -e 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=ubuntu/g' /etc/apache2/envvars
sed -i -e 's/export APACHE_RUN_GROUP=www-data/export APACHE_RUN_GROUP=ubuntu/g' /etc/apache2/envvars
sed -i -e 's/chown www-data:www-data/chown ubuntu:ubuntu/g' /etc/apache2/envvars
sudo sed -i -e 's/;sendmail_path =/sendmail_path = \/opt\/mailhog\/mailhog sendmail/g' /etc/php/7.0/fpm/pool.d/www.conf
sudo sed -i -e 's/;sendmail_path =/sendmail_path = \/opt\/mailhog\/mailhog sendmail/g' /etc/php/7.0/fpm/php.ini
sudo sed -i -e 's/;sendmail_path =/sendmail_path = \/opt\/mailhog\/mailhog sendmail/g' /etc/php/7.0/cli/php.ini
sudo sed -i -e 's/;sendmail_path =/sendmail_path = \/opt\/mailhog\/mailhog sendmail/g' /etc/php/7.0/apache2/php.ini

echo "-- Restart Apache --"
sudo /etc/init.d/apache2 restart
sudo /etc/init.d/php7.0-fpm restart

echo "-- Install Composer --"
#curl -s https://getcomposer.org/installer | php
#sudo mv composer.phar /usr/local/bin/composer
#sudo chmod +x /usr/local/bin/composer
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

echo "-- Install phpMyAdmin --"
wget -k https://files.phpmyadmin.net/phpMyAdmin/4.0.10.11/phpMyAdmin-4.0.10.11-english.tar.gz
sudo tar -xzvf phpMyAdmin-4.0.10.11-english.tar.gz -C /var/www/
sudo rm phpMyAdmin-4.0.10.11-english.tar.gz
sudo mv /var/www/phpMyAdmin-4.0.10.11-english/ /var/www/phpmyadmin

sudo update-rc.d apache2 defaults

echo "-- Setup databases --"
mysql -uroot -p123 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '123' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -uroot -p123 -e "CREATE DATABASE dev;";
#mysql -uroot -p123 dev -e 'CREATE TABLE `sessions` (`sess_id` VARCHAR(128) NOT NULL PRIMARY KEY, `sess_data` BLOB NOT NULL, `sess_time` INTEGER UNSIGNED NOT NULL, `sess_lifetime` MEDIUMINT NOT NULL) COLLATE utf8_bin, ENGINE = InnoDB;';

cat << EOF | sudo tee -a /var/www/app/web/index.php
<?php phpinfo();
EOF
sudo chown -R ubuntu:ubuntu /var/www

sed -i -e 's/#force_color_prompt=yes/force_color_prompt=yes/g' /home/ubuntu/.bashrc
wget -O xt  http://git.io/v3DBV && sudo chmod +x xt && sudo ./xt && sudo rm xt

sudo service mysql start
if [[ -f "/vagrant/db-dump.sql" ]]; then
  mysql -uroot -p123 dev < /vagrant/db-dump.sql
  echo 'loaded the db dump at db-dump.sql'
fi
mysql -uroot -p123 < /vagrant/mysql-5.7.sql
#sudo chown -R mysql:adm /etc/mysql
#sudo chown -R mysql:adm /usr/share/mysql
#sudo chown -R mysql:adm /usr/share/mysql-common

sudo service mailhog start
sudo service php7.0-fpm reload
sudo service php7.0-fpm restart
sudo service apache2 reload
sudo service apache2 restart
sudo service mysql reload
sudo service mysql restart

cat << EOF | sudo tee -a /home/ubuntu/.bash_aliases
alias app="cd /var/www/app"
EOF
sudo chown ubuntu:ubuntu /home/ubuntu/.bash_aliases

echo 'be advised, this runs only on Linux or Mac, not on windows, due to NFS sharing!'
echo 'please edit your hosts file, add both `app.dev` and `phpmyadmin.dev` as `192.168.100.100`'
echo 'mails will be intercepted by mailhog, located at `http://app.dev:8025`'
echo 'User/Passwords for mailhog and mysql are: user=root, password=123, db_scheme=dev'
echo 'for craft cms enable the db in `craft/config` as well as the debug mode'

