#!/bin/bash

GIT_ENV=`git --git-dir /vagrant/.git rev-parse --abbrev-ref HEAD`

sudo /opt/puppetlabs/bin/puppet apply /vagrant/manifests/site.pp --modulepath=/vagrant/site:/vagrant/modules
sudo rm -rf /etc/puppetlabs/code/environments/*
sudo mkdir -p /etc/puppetlabs/code/environments/$GIT_ENV
sudo cp -R /vagrant /etc/puppetlabs/code/environments/$GIT_ENV/.
sudo service puppetserver reload
sudo /opt/puppetlabs/bin/puppet agent -t --environment $GIT_ENV
