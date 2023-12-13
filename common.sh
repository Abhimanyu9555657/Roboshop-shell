nodejs () {
echo -e "\e[36m>>>>>>>> Create ${component} Service <<<<<<<<\e[0m"
cp ${component}.service /etc/systemd/system/${component}.service &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Mongodb Repo <<<<<<<<\e[0m"
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Install Nodejs Repos <<<<<<<<\e[0m"
dnf module disable nodejs -y &>>/tmp/roboshop.log
dnf module enable nodejs:18 -y &>>/tmp/roboshop.log
dnf install nodejs -y &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Creating Application user <<<<<<<<\e[0m"
${component}add roboshop &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>>  Deleting Old Content <<<<<<<<\e[0m"
rm -rf /app &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Creating Application Directory <<<<<<<<\e[0m"
mkdir /app &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Downloading Application Content <<<<<<<<\e[0m"
curl -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Extracting Application Content <<<<<<<<\e[0m"
cd /app &>>/tmp/roboshop.log
unzip /tmp/${component}.zip &>>/tmp/roboshop.log
cd /app &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Downloading Nodejs Dependency <<<<<<<<\e[0m"
npm install &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Installing Mongodb Client <<<<<<<<\e[0m"
dnf install mongodb-org-shell -y &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Downloading ${component} Schema <<<<<<<<\e[0m"
mongo --host mongodb.rdevops57online.com </app/schema/user.js &>>/tmp/roboshop.log

echo -e "\e[36m>>>>>>>> Starting ${component} Service <<<<<<<<\e[0m"
systemctl daemon-reload &>>/tmp/roboshop.log
systemctl enable ${component} &>>/tmp/roboshop.log
systemctl start ${component} &>>/tmp/roboshop.log
}
