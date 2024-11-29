#!/bin/bash -e

echo "Reading parameters"
TVM_TOKEN=$1
TARGET_ROLE_ARN=$2
TARGET_ROLE_EXTERNAL_ID=$3

echo "Preparing TVM payload"
LAMBDA="arn:aws:lambda:eu-west-1:095208641432:function:App_RoleRetriever"
PAYLOAD="{\"action\": \"getrole\", \"token\": \"${TVM_TOKEN}\", \"role\": \"${TARGET_ROLE_ARN}\", \"externalid\": \"${TARGET_ROLE_EXTERNAL_ID}\"}"
PAYLOAD_BASE64=$(echo $PAYLOAD | base64)

echo "Calling Lambda function"
aws lambda invoke --function-name "${LAMBDA}" --payload "${PAYLOAD}" --region eu-west-1 response.json
echo "Finished Lambda Call"

echo "Extracting temporary AWS credentials"
AWS_ACCESS_KEY_ID=$(cat response.json | jq -r . | jq .AccessKeyId | xargs)
AWS_SECRET_ACCESS_KEY=$(cat response.json | jq -r . | jq .SecretAccessKey | xargs)
AWS_SESSION_TOKEN=$(cat response.json | jq -r . | jq .SessionToken | xargs)
AWS_EXPIRATION=$(cat response.json | jq -r . | jq .Expiration | xargs)
echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"

echo "::add-mask::$AWS_SECRET_ACCESS_KEY"
echo "::add-mask::$AWS_SESSION_TOKEN"

echo "Setting AWS variables"
echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> $GITHUB_ENV
echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> $GITHUB_ENV
echo "AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN" >> $GITHUB_ENV
echo "AWS_EXPIRATION=$AWS_EXPIRATION" >> $GITHUB_ENV
