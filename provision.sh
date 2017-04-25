#!/bin/bash

apache_config_file="/etc/apache2/envvars"
php_config_file="/etc/php5/apache2/php.ini"
xdebug_config_file="/etc/php5/mods-available/xdebug.ini"
mysql_config_file="/etc/mysql/my.cnf"
default_apache_index="/var/www/html/index.html"

# This function is called at the very bottom of the file
main() {
	repositories_go
	update_go
	network_go
	tools_go
	apache_go
	mysql_go
	php_go
	autoremove_go
}

repositories_go() {
	echo "NOOP"
}

update_go() {
	# Update the server
	sudo apt-get update
	# apt-get -y upgrade
}

autoremove_go() {
	sudo apt-get -y autoremove
}


network_go() {
	IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
	sudo sed -i "s/^${IPADDR}.*//" /etc/hosts
	echo ${IPADDR} ubuntu.localhost >> /etc/hosts
}

tools_go() {
	# Install basic tools
	sudo apt-get install -y curl
	sudo apt-get install -y make
	sudo apt-get install -y openssl
	sudo apt-get install -y unzip
	sudo apt-get install -y vim
	sudo apt-get install -y tree
	sudo apt-get install -y git
}

apache_go() {
	# Install Apache

	echo "[vagrant provisioning] Installing apache2..."
	sudo apt-get install -y apache2 # installs apache and some dependencies
	sudo service apache2 restart # restarting for sanities' sake
	echo "[vagrant provisioning] Applying Apache vhost conf..."
	sudo rm -f /etc/apache2/sites-available/default
	sudo rm -f /etc/apache2/sites-enabled/000-default

	if [ ! -f "/etc/apache2/sites-available/default" ]; then
		cat << EOF > "/etc/apache2/sites-available/default"
<VirtualHost *:80>
	ServerAdmin webmaster@localhost

	DocumentRoot /var/www
	<Directory />
		Options FollowSymLinks
		AllowOverride All
	</Directory>
	<Directory /var/www/>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>

	ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
	<Directory /usr/lib/cgi-bin>
		AllowOverride All
		Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
		Order allow,deny
		Allow from all
	</Directory>

    ErrorLog /var/log/apache2/error.log
    LogLevel warn
    CustomLog /var/log/apache2/access.log combined

    Alias /doc/ /usr/share/doc/
    <Directory /usr/share/doc/>
        Options Indexes MultiViews FollowSymLinks
        AllowOverride All
        Order deny,allow
        Deny from all
        Allow from 127.0.0.0/255.0.0.0 ::1/128
    </Directory>

</VirtualHost>
EOF
	fi

	sudo ln -s /etc/apache2/sites-available/default /etc/apache2/sites-enabled/000-default
	a2enmod rewrite
	a2enmod actions
	a2enmod ssl
	sudo service apache2 restart
}

php_go() {
	sudo apt-get -y install php5 php5-curl php5-mysql php5-sqlite php5-xdebug php-pear

	sudo sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" ${php_config_file}
	sudo sed -i "s/display_errors = Off/display_errors = On/g" ${php_config_file}

	if [ ! -f "{$xdebug_config_file}" ]; then
		cat << EOF > ${xdebug_config_file}
zend_extension=xdebug.so
xdebug.remote_enable=1
xdebug.remote_connect_back=1
xdebug.remote_port=9000
xdebug.remote_host=10.0.2.2
EOF
	fi

	sudo service apache2 restart

	# Install latest version of Composer globally
	if [ ! -f "/usr/local/bin/composer" ]; then
		sudo curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
	fi

	# Install PHP Unit 4.8 globally
	if [ ! -f "/usr/local/bin/phpunit" ]; then
		sudo curl -O -L https://phar.phpunit.de/phpunit-old.phar
		sudo chmod +x phpunit-old.phar
		sudo mv phpunit-old.phar /usr/local/bin/phpunit
	fi
}

mysql_go() {
	# Install MySQL
	echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
	echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
	sudo apt-get -y install mysql-client mysql-server

	sudo sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" ${mysql_config_file}

	# Allow root access from any host
	echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION" | mysql -u root --password=root
	echo "GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION" | mysql -u root --password=root

	if [ -d "/vagrant/provision-sql" ]; then
		echo "Executing all SQL files in /vagrant/provision-sql folder ..."
		echo "-------------------------------------"
		for sql_file in /vagrant/provision-sql/*.sql
		do
			echo "EXECUTING $sql_file..."
	  		sudo time mysql -u root --password=root < $sql_file
	  		echo "FINISHED $sql_file"
	  		echo ""
		done
	fi

	sudo service mysql restart
}

main
exit 0
