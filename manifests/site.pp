node 'puppet-mom' {
  include ::role::puppet_mom
}

node 'puppet-cm01' {
  include ::role::puppet_cm
}

node default {
  include ::profile::base
}
