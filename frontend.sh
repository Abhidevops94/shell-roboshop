#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 |cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD


mkdir -p $LOGS_FOLDER
echo "script started excuting at: $(date)" | tee -a $LOG_FILE


if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "you are running with root access" | tee -a $LOG_FILE
fi

#Validate function takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
then
    echo -e "$2 is ... $G success $N" | tee -a $LOG_FILE
else
    echo -e "$2 is ... $R failure $N" | tee -a $LOG_FILE
    exit 1
fi
}

dnf module list nginx &>>$LOG_FILE
VALIDATE $? "listing ngnix module"

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling ngnix module"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enabling ngnix:1.24 module"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "installing ngnix module"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Enabled and starting ngnix service"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing the default content that web server is serving"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "Downloading the frontend content"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping the frontend content"

rm -rf /etc/nginx/nginx.conf
VALIDATE $? "Remove default nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "copying nginx conf file"

systemctl restart nginx
VALIDATE $? "Restarting nginx"

