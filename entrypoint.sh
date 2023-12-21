#!/bin/bash

set -ex

#aws s3 sync s3://kong-aws-ecs-jenkins/.ssh /root/.ssh

if [ -f /root/.ssh/id_rsa ]; then
  chmod 500 /root/.ssh/id_rsa
fi
/usr/bin/tini -- /usr/local/bin/jenkins.sh
