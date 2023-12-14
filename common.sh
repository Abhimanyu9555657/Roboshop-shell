log=tmp/roboshop.log

func_appreq() {
  echo -e "\e[36m>>>>>>>> Create ${component} Service <<<<<<<<<\e[0m"
  cp ${component}.service /etc/systemd/system/${component}.service app &>>${log}

  echo -e "\e[36m>>>>>>>> Create Application User <<<<<<<<<\e[0m"
  useradd roboshop &>>${log}

  echo -e "\e[36m>>>>>>>> Cleanup Existing Application Content <<<<<<<<<\e[0m"
  rm -rf /app &>>${log}

  echo -e "\e[36m>>>>>>>> Create Application Directory <<<<<<<<<\e[0m"
  mkdir /app &>>${log}

  echo -e "\e[36m>>>>>>>> Download Application Content <<<<<<<<<\e[0m"
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}

  echo -e "\e[36m>>>>>>>> Extract Application Content <<<<<<<<<\e[0m"
  cd /app
  unzip /tmp/${component}.zip &>>${log}
  cd /app
}

func_systemd() {
  echo -e "\e[36m>>>>>>>> Start ${component} Service <<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
  systemctl daemon-reload &>>${log}
  systemctl enable ${component} &>>${log}
  systemctl restart ${component} &>>${log}
}

func_schema_setup() {
 if [ "${schema_type}" == "mongodb" ]; then
    echo -e "\e[36m>>>>>>>> Install Mongo Client <<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    yum instal mongodb-org-shell -y &>>${log}
    echo -e "\e[36m>>>>>>>> Load User Schema <<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    mongo --host mongodb.rdevops57online.com </app/schema/${component}.js &>>${log}
 fi

 if ["${schema_type}" == "mysql"]; then
    echo -e "\e[36m>>>>>>>> Install Mysql Client <<<<<<<<\e[0m"
    yum install mysql -y &>>${log}

    echo -e "\e[36m>>>>>>>> Load Schema <<<<<<<<\e[0m"
    mysql -h mysql.rdevops57online.com -uroot -pRoboshop@1 </app/schema/${component}.sql &>>${log}
 fi

}

func_nodejs() {
  log=/tmp/roboshop.log

  echo -e "\e[36m>>>>>>>> Create Mongodb Repo <<<<<<<<\e[0m"
  cp mongo.rep /etc/yum.repos.d/mongo.repo &>>${log}

  echo -e "\e[36m>>>>>>>> Install NodeJS Repos <<<<<<<<\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x bash &>>${log}

  echo -e "\e[36m>>>>>>>> Install NodeJS <<<<<<<<\e[0m"
  yum install nodejs -y &>>${log}

  func_appreq

  echo -e "\e[36m>>>>>>>> Download NodeJS Dependency <<<<<<<<\e[0m"
  npm install &>>${log}

  func_schema_setup

  func_systemd
}

func_java() {
 echo -e "\e[36m>>>>>>>> Install Maven <<<<<<<<\e[0m"
 yum install maven -y &>>${log}

func_appreq

 echo -e "\e[36m>>>>>>>> Build ${component} Service <<<<<<<<\e[0m"
 mvn clean package &>>${log}
 mv target/${component}-1.0.jar ${component}.jar

 func_systemd
}

 func_python() {

 cp ${component}.service /etc/systemd/system/${component}.service &>>${log}
 yum install python36 gcc python3-devil -y &>>${log}

 func_appreq

 echo -e "\e[36m>>>>>>>> Build ${component} Service <<<<<<<<\e[0m"
 pip3.6 install -r requirement.txt &>>${log}

 function_systemd
}