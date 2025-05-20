#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-02b4d462dce5895c1"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalog" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z0685077B05N47RTNXID"
DOMAIN_NAME="abhi84s-daws.site"

for instance in ${INSTANCES[@]}
do
    INSTANCES_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-02b4d462dce5895c1 --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=test}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance != "frontend" ]
    then
        IP=aws ec2 describe-instances --instance-ids $INSTANCES_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text
        echo "$instance IP address: $IP"
    else
        IP=aws ec2 describe-instances --instance-ids $INSTANCES_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text
        echo "$instance IP address: $IP"
done