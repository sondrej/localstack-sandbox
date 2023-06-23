#!/bin/bash

echo "Create localstack sns/sqs topics/queues"

awslocal sns create-topic --name sandbox-topic

awslocal sqs create-queue --queue-name sandbox-queue --attributes '{"RedrivePolicy":"{\"deadLetterTargetArn\":\"arn:aws:sqs:eu-west-1:00000000:employee-transaction-inbound-dlq\",\"maxReceiveCount\":\"5\"}", "ReceiveMessageWaitTimeSeconds":"20" }'
