#!/bin/bash

MAJOR_VERSION=`grep -Eo ' [0-9].' /etc/redhat-release | grep -Eo '[0-9]'`

sudo rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-$MAJOR_VERSION.noarch.rpm
sudo yum clean all
sudo yum makecache
sudo yum install -y puppet-agent git

GIT_ENV=`git --git-dir /vagrant/.git rev-parse --abbrev-ref HEAD`
sudo sed "s/\(^.*environment = \).*/\1$GIT_ENV/" /etc/puppetlabs/puppet/puppet.conf
