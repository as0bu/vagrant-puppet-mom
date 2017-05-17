class profile::base::puppet_agent (

  $puppet_master = hiera('puppet::puppet_master')

){

  class { '::puppet':
    server => false,
    server_foreman => false,
    puppetmaster => $puppet_master,
  }

}
