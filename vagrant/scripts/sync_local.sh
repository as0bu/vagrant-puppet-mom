#!/bin/bash

GIT_ENV=`git rev-parse --abbrev-ref HEAD`

vagrant ssh $1 -c "sudo rm -rf /etc/puppetlabs/code/environments/$GIT_ENV"
vagrant ssh $1 -c "sudo mkdir /etc/puppetlabs/code/environments/$GIT_ENV"
vagrant ssh $1 -c "sudo cp -R /vagrant/* /etc/puppetlabs/code/environments/$GIT_ENV/."
vagrant ssh $1 -c "sudo service puppetserver reload"
