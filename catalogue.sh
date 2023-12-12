echo -e "\e[36m>>>>>>>> Create Catalogue Service <<<<<<<<\e[0m"
cp catalogue.service /etc/systemd/system/catalogue.service

echo -e "\e[36m>>>>>>>> Mongodb Repo <<<<<<<<\e[0m"
cp mongo.repo /etc/yum.repos.d/mongo.repo

echo -e "\e[36m>>>>>>>> Install Nodejs Repos <<<<<<<<\e[0m"
dnf module disable nodejs -y
dnf module enable nodejs:18 -y
dnf install nodejs -y

echo -e "\e[36m>>>>>>>> Creating Application User <<<<<<<<\e[0m"
useradd roboshop

echo -e "\e[36m>>>>>>>>  Deleting Old Content <<<<<<<<\e[0m"
rm -rf /app

echo -e "\e[36m>>>>>>>> Creating Application Directory <<<<<<<<\e[0m"
mkdir /app

echo -e "\e[36m>>>>>>>> Downloading Application Content <<<<<<<<\e[0m"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip

echo -e "\e[36m>>>>>>>> Extracting Application Content <<<<<<<<\e[0m"
cd /app
unzip /tmp/catalogue.zip
cd /app

echo -e "\e[36m>>>>>>>> Downloading Nodejs Dependency <<<<<<<<\e[0m"
npm install

echo -e "\e[36m>>>>>>>> Installing Mongodb Client <<<<<<<<\e[0m"
dnf install mongodb-org-shell -y

echo -e "\e[36m>>>>>>>> Downloading Catalogue Schema <<<<<<<<\e[0m"
mongo --host mongodb.rdevops57online.com </app/schema/catalogue.js

echo -e "\e[36m>>>>>>>> Starting Catalogue Service <<<<<<<<\e[0m"
systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue
