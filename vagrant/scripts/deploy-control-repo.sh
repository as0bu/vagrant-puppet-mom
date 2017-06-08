#!/bin/bash
vagrant ssh $1 -c 'sudo r10k deploy environment --puppetfile'
vagrant ssh $1 -c 'sudo /opt/puppetlabs/bin/puppet agent -t'
