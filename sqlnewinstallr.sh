#!/bin/bash

# Update the package list
sudo apt-get update

# Install MySQL
sudo apt-get install -y mysql-server

sudo apt-get install -y apache2

sudo apt-get install -y php libapache-mod-php php-mysql

sudo systemctl restart apache2

# Prompt for MySQL root password
echo "Enter the MySQL root password: "
read -s root_password

# Set the MySQL root password
sudo mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$root_password';"

# Prompt for new MySQL user
echo "Enter the new MySQL username: "
read username

# Prompt for new MySQL user password
echo "Enter the new MySQL user password: "
while true; do
  read -s user_password
  if [[ ${#user_password} -ge 12 && ${user_password} =~ [A-Z] && ${user_password} =~ [a-z] && ${user_password} =~ [0-9] ]]; then
    break
  else
    echo "Password must be at least 12 characters long and contain uppercase letters, lowercase letters, and numbers. Please try again."
  fi
done

# Prompt for new MySQL database name
echo "Enter the new MySQL database name: "
read database_name

# Check if the user already exists, drop if necessary
user_exists=$(sudo mysql -uroot -p"$root_password" -se "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username');")

if [[ "$user_exists" -eq 1 ]]; then
  echo "User '$username' already exists. Dropping the existing user."
  sudo mysql -uroot -p"$root_password" -e "DROP USER '$username'@'%';"
fi

# Create a new MySQL user and database
sudo mysql -uroot -p"$root_password" -e "CREATE USER '$username'@'%' IDENTIFIED BY '$user_password';"
sudo mysql -uroot -p"$root_password" -e "CREATE DATABASE $database_name;"

# Grant privileges to the new user
sudo mysql -uroot -p"$root_password" -e "GRANT ALL PRIVILEGES ON $database_name.* TO '$username'@'%';"

# Flush privileges (important after user creation/updates)
sudo mysql -uroot -p"$root_password" -e "FLUSH PRIVILEGES;"

# Restart the MySQL service
sudo service mysql restart

# Secure the MySQL installation
sudo mysql_secure_installation

echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

sudo systemctl restart apache2 

echo "Apache, MySQL, and PHP are installed and configured."
echo "You can verify the PHP installation by visiting http://your_raspberry_pi_ip/info.php"


# This is the working one you knob. (to myself not to you who sees this, ur cool)