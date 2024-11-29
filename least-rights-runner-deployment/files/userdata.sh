http_proxy='http://emea-aws-webproxy.service.cloud.local:3128'
https_proxy='http://emea-aws-webproxy.service.cloud.local:3128'
no_proxy='169.254.169.254'
export HTTP_PROXY="$http_proxy"
export HTTPS_PROXY="$https_proxy"
export NO_PROXY="$no_proxy"

echo "export HTTP_PROXY=\"$http_proxy\"" >> /etc/profile
echo "export HTTPS_PROXY=\"$https_proxy\"" >> /etc/profile
echo "export NO_PROXY=\"$no_proxy\"" >> /etc/profile

yum install docker -y
mkdir /etc/systemd/system/docker.service.d
rm -f /etc/systemd/system/docker.service.d/proxy.conf
echo "[Service]" >> /etc/systemd/system/docker.service.d/proxy.conf
echo "Environment=\"HTTP_PROXY=$http_proxy\"" >> /etc/systemd/system/docker.service.d/proxy.conf
echo "Environment=\"HTTPS_PROXY=$https_proxy\"" >> /etc/systemd/system/docker.service.d/proxy.conf
echo "Environment=\"NO_PROXY=$no_proxy\"" >> /etc/systemd/system/docker.service.d/proxy.conf
systemctl daemon-reload
systemctl restart docker
systemctl enable docker


cd /opt
mkdir actions-runner
cd actions-runner

curl -o actions-runner-linux-x64-2.279.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.279.0/actions-runner-linux-x64-2.279.0.tar.gz
echo "50d21db4831afe4998332113b9facc3a31188f2d0c7ed258abf6a0b67674413a  actions-runner-linux-x64-2.279.0.tar.gz" | shasum -a 256 -c || exit 1
tar xzf ./actions-runner-linux-x64-2.279.0.tar.gz

echo "http_proxy=http://emea-aws-webproxy.service.cloud.local:3128" >> ./.env
echo "https_proxy=http://emea-aws-webproxy.service.cloud.local:3128" >> ./.env