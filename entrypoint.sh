#!/bin/bash

set -e

#aws s3 sync s3://kong-aws-ecs-jenkins/.ssh /root/.ssh

if [ -f /root/.ssh/id_rsa ]; then
  chmod 500 /root/.ssh/id_rsa
fi
git config --global user.name "waytoarcher"
git config --global user.email waytoarcher@gmail.com
ssh-keyscan -H github.com > /etc/ssh/ssh_known_hosts
/usr/bin/tini -- /usr/local/bin/jenkins.sh
