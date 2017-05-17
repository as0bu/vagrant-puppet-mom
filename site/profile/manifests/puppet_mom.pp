class profile::puppet_mom {

  if $::user_exists_vagrant {
    $_autosign_entries = ['*.localvm']
    $_agent_environment = $::vagrant_git_env
  }

  class { '::puppet':
    server => true,
    server_foreman => false,
    server_reports => 'puppetdb',
    server_storeconfigs_backend => 'puppetdb',
    server_puppetdb_host => $::fqdn,
    server_external_nodes => '',
    server_environments => [],
    autosign_entries => $_autosign_entries,
    environment => $_agent_environment,
    hiera_config => '/etc/puppetlabs/puppet/hiera.yaml'
  }

  class { '::puppetdb':
    manage_firewall => false,
    require => Class['::puppet'],
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

  class { '::puppetboard':
    manage_git => true,
    manage_virtualenv => true,
    offline_mode => true,
    require => Class['::puppet'],
    default_environment => $::environment,
  }

  class { '::apache':
  }

  class { '::apache::mod::wsgi':
    wsgi_socket_prefix => '/var/run/wsgi',
  }

  class { '::puppetboard::apache::vhost':
    vhost_name => $::fqdn,
    port => 443,
    ssl => true,
    ssl_cert => "/etc/puppetlabs/puppet/ssl/certs/${::fqdn}.pem",
    ssl_key => "/etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem",
  }
}
