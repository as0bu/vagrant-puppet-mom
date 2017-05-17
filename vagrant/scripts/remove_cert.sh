#!/bin/bash

vagrant ssh puppet-mom -c "sudo /opt/puppetlabs/bin/puppet cert clean $1"
vagrant ssh puppet-mom -c "sudo /opt/puppetlabs/bin/puppet node deactivate $1"
vagrant ssh puppet-mom -c "sudo service puppetserver reload"

