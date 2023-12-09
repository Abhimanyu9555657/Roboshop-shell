cp mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-org -y
# Update Listen address from 127.0.0.1 to 0.0.0.0

systemctl enable mongod
systemctl restart mongod