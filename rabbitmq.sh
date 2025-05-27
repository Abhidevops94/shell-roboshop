#!/bin/bash

START_TIME=$(date +%s)
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

echo "please enter rabbitmq password to setup"
read -s RABBITMQ_PASSWORD

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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Copying rebbitmq repo"

dnf install rabbitmq-server -y
VALIDATE $? "installing rebbitmq"

systemctl enable rabbitmq-server
VALIDATE $? "enabling rebbitmq"

systemctl start rabbitmq-server
VALIDATE $? "starting rebbitmq"

id roboshop
if [ $? -ne 0 ]
then
    rabbitmqctl add_user roboshop $RABBITMQ_PASSWORD &>>$LOG_FILE
    VALIDATE $? "Adding application User"
else
    echo -e "system user roboshop already created ...$Y SKIPPING $N"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "setting permission for roboshop"



END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "script is completed successfully, $Y time taken: $TOTAL_TIME $N" | tee -a $LOG_FILE