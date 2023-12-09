dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y
dnf module enable redis:remi-6.2 -y
dnf install redis -y
# Update listen address vim /etc/redis.conf & vim /etc/redis/redis.conf
systemctl enable redis
systemctl restart redis