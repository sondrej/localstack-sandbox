#!/bin/bash

echo "Subscribing queues to topics and create event source mapping for lambdas"

awslocal sns subscribe --topic-arn arn:aws:sns:eu-west-1:000000000000:sandbox-topic --protocol sqs --notification-endpoint arn:aws:sqs:eu-west-1:00000000:sandbox-queue --attributes '{"RawMessageDelivery":"true"}'

awslocal lambda create-event-source-mapping --function-name sandbox-handler --batch-size 1 --event-source-arn arn:aws:sqs:eu-west-1:00000000:sandbox-queue