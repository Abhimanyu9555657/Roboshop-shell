echo -e "\e[36m>>>>>>>> Create Catalogue Service <<<<<<<<\e[0m"
cp catalogue.service /etc/systemd/system/catalogue.service &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Mongodb Repo <<<<<<<<\e[0m"
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Install Nodejs Repos <<<<<<<<\e[0m"
dnf module disable nodejs -y &>>/tmp/roboshop.log
dnf module enable nodejs:18 -y &>>/tmp/roboshop.log
dnf install nodejs -y &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Creating Application User <<<<<<<<\e[0m"
useradd roboshop &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>  Deleting Old Content <<<<<<<<\e[0m"
rm -rf /app &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Creating Application Directory <<<<<<<<\e[0m"
mkdir /app &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Downloading Application Content <<<<<<<<\e[0m"
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Extracting Application Content <<<<<<<<\e[0m"
cd /app &>>/tmp/roboshop.log
unzip /tmp/catalogue.zip &>>/tmp/roboshop.log
cd /app &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Downloading Nodejs Dependency <<<<<<<<\e[0m"
npm install &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Installing Mongodb Client <<<<<<<<\e[0m"
dnf install mongodb-org-shell -y &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Downloading Catalogue Schema <<<<<<<<\e[0m"
mongo --host mongodb.rdevops57online.com </app/schema/catalogue.js &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Starting Catalogue Service <<<<<<<<\e[0m"
systemctl daemon-reload &>>/tmp/roboshop.log
systemctl enable catalogue &>>/tmp/roboshop.log
systemctl start catalogue &>>/tmp/roboshop.log



