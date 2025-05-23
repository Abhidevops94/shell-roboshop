#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-02b4d462dce5895c1"  # replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalog" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z0685077B05N47RTNXID"  # replace with your ZONE ID
DOMAIN_NAME="abhi84s-daws.site"  # replace with your domain

for instance in ${INSTANCES[@]}
do
    INSTANCES_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)

    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCES_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCES_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        RECORD_NAME="$DOMAIN_NAME"
    fi 

    echo "$instance IP address: $IP"

    # Create a record set
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch "{
        \"Comment\": \"Creating or updating a record set for $instance\",
        \"Changes\": [{
            \"Action\": \"UPSERT\",
            \"ResourceRecordSet\": {
                \"Name\": \"$RECORD_NAME\",
                \"Type\": \"A\",  # Use A record for IP address
                \"TTL\": 1,
                \"ResourceRecords\": [{\"Value\": \"$IP\"}]
            }
        }]
    }"

    if [ $? -ne 0 ]; then
        echo "Failed to update DNS for $instance"
    else
        echo "DNS updated for $instance"
    fi
done
