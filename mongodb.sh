#!/bin/bash

source ./common.sh
app_name=mongodb

check_root

cp mongodb.repo /etc/yum.repos.d/mongodb.repo
VALIDATE $? "COPYING Mongodb repo" 

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Insatlling Mongodb server"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling Mongodb"
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Start Mangodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing mongodb conf file for remote connection"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restarting mongodb"

print_time