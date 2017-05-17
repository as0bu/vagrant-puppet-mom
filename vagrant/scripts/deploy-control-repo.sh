#!/bin/bash
vagrant ssh $1 -c 'sudo GIT_SSL_NO_VERIFY=true r10k deploy environment --puppetfile'
vagrant ssh $1 -c 'sudo /opt/puppetlabs/bin/puppet agent -t'
