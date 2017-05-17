class profile::puppet_cm (

  $puppet_mom = hiera('puppet::puppet_mom')

){

  include ::nginx

  if $::user_exists_vagrant {
    $_autosign_entries = ['*.localvm']
    $_agent_environment = $::vagrant_git_env
    $_raw_append = 'set $puppet_mom "192.168.58.10";'
    $_mom_proxy = "https://\$puppet_mom:8140/\$1"
  }
  else {
    $_mom_proxy = "https://${puppet_mom}:8140/\$1"
  }

  class { '::puppet':
    server => true,
    server_foreman => false,
    server_reports => 'puppetdb',
    server_storeconfigs_backend => 'puppetdb',
    ca_server => $puppet_mom,
    server_ca => false,
    server_puppetdb_host => $puppet_mom,
    server_external_nodes => '',
    server_environments => [],
    autosign_entries => $_autosign_entries,
    environment => $_agent_environment,
    server_port => '8200',
    server_ip => '127.0.0.1',
    server_allow_header_cert_info => true,
    puppetmaster => $puppet_mom,
    hiera_config => '/etc/puppetlabs/puppet/hiera.yaml'
  }

  class { '::r10k':
    remote => 'https://www.github.com/as0bu/vagrant-puppet-mom.git',
    require => Class['::puppet'],
  }

  class { '::hiera':
    hierarchy => [
      'nodes/%{::fqdn}',
      'datacenter/%{::datacenter}',
      'common',
    ],
    datadir_manage => false,
    require => Class['::puppet'],
  }

  nginx::resource::server { 'puppet':
    ensure               => present,
    server_name          => ['puppet'],
    listen_port          => 8140,
    ssl                  => true,
    ssl_redirect         => true,
    ssl_cert             => "/etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem",
    ssl_key              => "/etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem",
    ssl_port             => 8140,
    server_cfg_append    => {
      'ssl_crl'                => '/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem',
      'ssl_client_certificate' => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
      'ssl_verify_client'      => 'optional',
      'ssl_verify_depth'       => 1,
    },
    use_default_location => false,
    access_log           => '/var/log/nginx/puppet_access.log',
    error_log            => '/var/log/nginx/puppet_error.log',
    raw_append           => $_raw_append,
    require              => File['/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem'],
  }

  nginx::resource::location { '~ ^/(.*/certificate.*)':
    proxy => $_mom_proxy,
    server => 'puppet',
    ssl => true,
    ssl_only => true,
    priority => 500,
  } 

  nginx::resource::location { '~ ^/(puppet-ca.*)':
    proxy => $_mom_proxy,
    server => 'puppet',
    ssl => true,
    ssl_only => true,
    priority => 505,
  } 

  nginx::resource::location { '/':
    proxy => "https://127.0.0.1:8200/",
    server => 'puppet',
    ssl => true,
    ssl_only => true,
    priority => 510,
    proxy_set_header => [ 'Host $host',
                          'X-Real-IP $remote_addr',
                          'X-Forwarded-For $proxy_add_x_forwarded_for',
                          'Proxy ""',
                          'X-Client-Verify $ssl_client_verify',
                          'X-Client-DN $ssl_client_s_dn',
                          'X-SSL-Subject $ssl_client_s_dn',
                          'X-SSL-Issuer $ssl_client_i_dn',
    ],
  } 

  file { '/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem':
    ensure => file,
    mode => '0644',
    group => 'puppet',
    owner => 'puppet',
    content => file('/etc/puppetlabs/puppet/ssl/ca/ca_crl.pem'),
    require => File['/etc/puppetlabs/puppet/ssl/ca'],
  }

  file { '/etc/puppetlabs/puppet/ssl/ca':
    ensure => directory,
    mode => '0755',
    group => 'puppet',
    owner => 'puppet',
    require => Class['::puppet'],
  }

}
