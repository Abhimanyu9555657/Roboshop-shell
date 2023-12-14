log=tmp/roboshop.log
echo $?

func_appreq() {
  echo -e "\e[36m>>>>>>>> Create ${component} Service <<<<<<<<<\e[0m"
  echo $?
  cp ${component}.service /etc/systemd/system/${component}.service app &>>${log}
  echo $?

  echo -e "\e[36m>>>>>>>> Create Application User <<<<<<<<<\e[0m"
  echo $?
  useradd roboshop &>>${log}
  echo $?

  echo -e "\e[36m>>>>>>>> Cleanup Existing Application Content <<<<<<<<<\e[0m"
  echo $?
  rm -rf /app &>>${log}
  echo $?

  echo -e "\e[36m>>>>>>>> Create Application Directory <<<<<<<<<\e[0m"
  echo $?
  mkdir /app &>>${log}
  echo $?

  echo -e "\e[36m>>>>>>>> Download Application Content <<<<<<<<<\e[0m"
  echo $?
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
  echo $?
  echo -e "\e[36m>>>>>>>> Extract Application Content <<<<<<<<<\e[0m"
  echo $?
  cd /app
  echo $?
  unzip /tmp/${component}.zip &>>${log}
  echo $?
  cd /app
  echo $?
}

func_systemd() {
  echo -e "\e[36m>>>>>>>> Start ${component} Service <<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
  echo $?
  systemctl daemon-reload &>>${log}
  echo $?
  systemctl enable ${component} &>>${log}
  echo $?
  systemctl restart ${component} &>>${log}
  echo $?
}

func_schema_setup() {
 if [ "${schema_type}" == "mongodb" ]; then
    echo -e "\e[36m>>>>>>>> Install Mongo Client <<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    yum instal mongodb-org-shell -y &>>${log}
    echo $?
    echo -e "\e[36m>>>>>>>> Load User Schema <<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    echo $?
    mongo --host mongodb.rdevops57online.com </app/schema/${component}.js &>>${log}
    echo $?
 fi

 if ["${schema_type}" == "mysql"]; then
    echo -e "\e[36m>>>>>>>> Install Mysql Client <<<<<<<<\e[0m"
    yum install mysql -y &>>${log}
    echo $?

    echo -e "\e[36m>>>>>>>> Load Schema <<<<<<<<\e[0m"
    mysql -h mysql.rdevops57online.com -uroot -pRoboshop@1 </app/schema/${component}.sql &>>${log}
    echo $?
 fi

}

func_nodejs() {
  log=/tmp/roboshop.log
  echo $?

  echo -e "\e[36m>>>>>>>> Create Mongodb Repo <<<<<<<<\e[0m"
  echo $?
  cp mongo.rep /etc/yum.repos.d/mongo.repo &>>${log}
  echo $?

  echo -e "\e[36m>>>>>>>> Install NodeJS Repos <<<<<<<<\e[0m"
  echo $?
  curl -sL https://rpm.nodesource.com/setup_lts.x bash &>>${log}
  echo $?

  echo -e "\e[36m>>>>>>>> Install NodeJS <<<<<<<<\e[0m"
  echo $?
  yum install nodejs -y &>>${log}
  echo $?

  func_appreq

  echo -e "\e[36m>>>>>>>> Download NodeJS Dependency <<<<<<<<\e[0m"
  echo $?
  npm install &>>${log}
  echo $?

  func_schema_setup

  func_systemd
}

func_java() {
 echo -e "\e[36m>>>>>>>> Install Maven <<<<<<<<\e[0m"
 echo $?
 yum install maven -y &>>${log}
 echo $?

func_appreq

 echo -e "\e[36m>>>>>>>> Build ${component} Service <<<<<<<<\e[0m"
 echo $?
 mvn clean package &>>${log}
 echo $?
 mv target/${component}-1.0.jar ${component}.jar
 echo $?

 func_systemd
}

func_python() {

 cp ${component}.service /etc/systemd/system/${component}.service &>>${log}
 echo $?
 yum install python36 gcc python3-devil -y &>>${log}
 echo $?
 func_appreq

 echo -e "\e[36m>>>>>>>> Build ${component} Service <<<<<<<<\e[0m"
 echo $?
 pip3.6 install -r requirement.txt &>>${log}
 echo $?

 function_systemd
}
