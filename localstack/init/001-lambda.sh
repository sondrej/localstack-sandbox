#!/bin/sh

echo "Create localstack lambdas"

cd /tmp/app

# node /docker-entrypoint-initaws.d/convert-env-to-csv.js .env-test .env-test.csv
# envStr=$(cat .env-test.csv)

zip -jr lambdas.zip ./dist/lambdas

awslocal lambda create-function \
    --function-name sandbox-handler \
    --runtime nodejs18.x \
    --zip-file fileb:///tmp/app/lambdas.zip \
    --handler "sandbox-handler.handler" \
    --role local-role