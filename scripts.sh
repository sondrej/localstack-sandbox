#!/bin/bash
set -euo pipefail

function usage() {
    echo "Usage"
    echo -e "build: force rebuild of containers"
    echo -e "start: start services"
    echo -e "  aws: start aws services"
    echo -e "  consumers: start consumer services"
    echo -e "stop: stop services"
    echo -e "msg: send a message"
    echo -e "  -h\t display help"
    echo -e "  -b\t body: message body"
    echo -e "  -r\t resource: resource name"
    echo -e "event: send an event"
    echo -e "  -h\t display help"
    echo -e "  -b\t body: event body"
    echo -e "  -r\t resource: resource name"
    echo -e "dlq: get all messages in dead letter queues"
    echo -e "  purge: get and purge dead letter queues"
}

[ -z "${1:-}" ] && usage && exit 1

function localstack_exec() {
  docker exec -i localstack_sandbox sh -c "$*"
  return $?
}

if [[ "$1" == "start" ]]; then
  [[ "$2" == "aws" ]] && docker-compose up localstack && exit $?
  [[ "$2" == "consumers" ]] && docker-compose up apples bananas pineapples fruitcake && exit $?
  
  echo "Expected one of aws or consumers to start" && usage && exit 1
fi
if [[ "$1" == "dlq" ]]; then
  types=( apple banana pineapple )
  for type in "${types[@]}"; do
    echo "Receiving up to 10 messages in $type-dlq"
    localstack_exec "awslocal sqs receive-message --queue-url http://localhost:4566/000000000000/$type-dlq --max-number-of-messages 10 --wait-time-seconds 1"
  done
  if [[ "${2-}" == "purge" ]]; then
    for type in "${types[@]}"; do
      echo "Purging all messages in queue $type-dlq"
      localstack_exec "awslocal sqs purge-queue --queue-url http://localhost:4566/000000000000/$type-dlq"
    done
  fi
  exit 0
fi
[[ "$1" == "build" ]] && docker-compose build --no-cache && exit $?
[[ "$1" == "stop" ]] && docker-compose down && exit $?

body=""
resource=""
s3Content=""
command="${1}"

shift

while getopts "hr:b:c:" opt; do
  case $opt in
    h) usage
      exit 0
      ;;
    r) 
      resource="$OPTARG"
      ;;
    b)
      body="$OPTARG"
      ;;
    c)
      s3Content="$OPTARG"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

[ -z "$resource" ] && echo "-r resource arg is required" && usage && exit 1
[ -z "$body" ] && echo "-b body arg is required" && usage && exit 1

if [ -n "$s3Content" ]; then
  echo "Sending s3 item to $resource"
  key="$body"
  path="/s3items/$key"
  localstack_exec "[ ! -d /s3items ] && mkdir /s3items || exit 0"
  localstack_exec "echo $s3Content > $path"
  localstack_exec "awslocal s3 cp $path s3://$resource/$key"
  #localstack_exec "rm $path"
fi

if [[ "$command" == "msg" ]]; then
  echo "Sending message to $resource"
  localstack_exec "awslocal sqs send-message --queue-url http://localhost:4566/000000000000/$resource --message-body \"$body\""
fi

if [[ "$command" == "event" ]]; then
  echo "Sending event to $resource"
  localstack_exec "awslocal sns publish --topic-arn arn:aws:sns:eu-west-1:000000000000:$resource --message \"$body\""
fi



