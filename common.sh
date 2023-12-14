log=tmp/roboshop.log

func_exit_status() {
  if [$? -eq 0]; then
      echo -e "\e[32m Success \e[0m"
    else
      echo -e "\e[31m Failure \e[0m"
  fi
}
func_appreq() {
  echo -e "\e[36m>>>>>>>> Create ${component} Service <<<<<<<<<\e[0m"
  cp ${component}.service /etc/systemd/system/${component}.service app &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>> Create Application User <<<<<<<<<\e[0m"
  func_exit_status
  useradd roboshop &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>> Cleanup Existing Application Content <<<<<<<<<\e[0m"
  rm -rf /app &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>> Create Application Directory <<<<<<<<<\e[0m"
  func_exit_status
  mkdir /app &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>> Download Application Content <<<<<<<<<\e[0m"
  func_exit_status
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${log}
  echo -e "\e[36m>>>>>>>> Extract Application Content <<<<<<<<<\e[0m"
  func_exit_status
  cd /app
  func_exit_status
  unzip /tmp/${component}.zip &>>${log}
  echo $?
  cd /app
  func_exit_status
}

func_systemd() {
  echo -e "\e[36m>>>>>>>> Start ${component} Service <<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
  systemctl daemon-reload &>>${log}
  systemctl enable ${component} &>>${log}
  systemctl restart ${component} &>>${log}
  func_exit_status
}

func_schema_setup() {
 if [ "${schema_type}" == "mongodb" ]; then
    echo -e "\e[36m>>>>>>>> Install Mongo Client <<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    yum instal mongodb-org-shell -y &>>${log}
    func_exit_status
    echo -e "\e[36m>>>>>>>> Load User Schema <<<<<<<<\e[0m" | tee -a /tmp/roboshop.log
    func_exit_status
    mongo --host mongodb.rdevops57online.com </app/schema/${component}.js &>>${log}
    func_exit_status
 fi

 if ["${schema_type}" == "mysql"]; then
    echo -e "\e[36m>>>>>>>> Install Mysql Client <<<<<<<<\e[0m"
    yum install mysql -y &>>${log}
    func_exit_status

    echo -e "\e[36m>>>>>>>> Load Schema <<<<<<<<\e[0m"
    mysql -h mysql.rdevops57online.com -uroot -pRoboshop@1 </app/schema/${component}.sql &>>${log}
    func_exit_status
 fi

}

func_nodejs() {
  log=/tmp/roboshop.log
  echo -e "\e[36m>>>>>>>> Create Mongodb Repo <<<<<<<<\e[0m"
  cp mongo.rep /etc/yum.repos.d/mongo.repo &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>> Install NodeJS Repos <<<<<<<<\e[0m"
  curl -sL https://rpm.nodesource.com/setup_lts.x bash &>>${log}
  func_exit_status

  echo -e "\e[36m>>>>>>>> Install NodeJS <<<<<<<<\e[0m"
  yum install nodejs -y &>>${log}
  func_exit_status


  func_appreq

  echo -e "\e[36m>>>>>>>> Download NodeJS Dependency <<<<<<<<\e[0m"
  npm install &>>${log}
  func_exit_status

  func_schema_setup

  func_systemd
}

func_java() {
 echo -e "\e[36m>>>>>>>> Install Maven <<<<<<<<\e[0m"
 yum install maven -y &>>${log}
 func_exit_status

func_appreq

 echo -e "\e[36m>>>>>>>> Build ${component} Service <<<<<<<<\e[0m"
 mvn clean package &>>${log}
 func_exit_status
 mv target/${component}-1.0.jar ${component}.jar
 func_exit_status

 func_systemd
}

func_python() {

 cp ${component}.service /etc/systemd/system/${component}.service &>>${log}
 yum install python36 gcc python3-devil -y &>>${log}
 func_exit_status
 func_appreq

 echo -e "\e[36m>>>>>>>> Build ${component} Service <<<<<<<<\e[0m"
 pip3.6 install -r requirement.txt &>>${log}
 func_exit_status

 function_systemd
}
