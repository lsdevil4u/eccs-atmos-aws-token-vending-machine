# export HTTP_PROXY=http://emea-aws-webproxy.service.cloud.local:3128
# export HTTPS_PROXY=http://emea-aws-webproxy.service.cloud.local:3128
# export NO_PROXY=169.254.169.254

echo "usage: assume_role.sh UniqueSessionName InstanceRoleName"
echo "downloading instance profile role credentials..."

credentialUrl="http://169.254.169.254/latest/meta-data/iam/security-credentials/$2"
echo "fetching $credentialUrl" 
curl -s $credentialUrl > cred.json
echo $(cat cred.json| jq .AccessKeyId | xargs)

echo "assuming instance profile role..."

export AWS_ACCESS_KEY_ID=$(cat cred.json| jq .AccessKeyId | xargs)
export AWS_SECRET_ACCESS_KEY=$(cat cred.json| jq .SecretAccessKey| xargs)
export AWS_SESSION_TOKEN=$(cat cred.json| jq .Token| xargs)
export AWS_EXPIRATION=$(cat cred.json| jq .Credentials.Expiration| xargs)

rm -f cred.json
