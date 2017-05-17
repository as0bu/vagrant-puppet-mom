#!/bin/bash

sudo rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-6.noarch.rpm
sudo yum clean all
sudo yum makecache
sudo yum install -y puppet-agent git

GIT_ENV=`git --git-dir /vagrant/.git rev-parse --abbrev-ref HEAD`
sudo sed "s/\(^.*environment = \).*/\1$GIT_ENV/" /etc/puppetlabs/puppet/puppet.conf
