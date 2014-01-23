node /sandbox[0-9]+.*/{

  case $osfamily {
    'Windows':{
      #class {'windows_common':}
      #class {'windows_common::configuration::disable_firewalls':}
      #class {'windows_common::configuration::enable_auto_update':}
      #class {'windows_common::configuration::ntp':}
#      class {'mingw':}
      class {'windows_openssl':}
      #class { 'openstack_hyper_v':
        # Services
      #  nova_compute              => true,
        # Network
      #  network_manager           => 'nova.network.manager.FlatDHCPManager',
        # Rabbit
      #  rabbit_hosts              => false,
      #  rabbit_host               => 'localhost',
      #  rabbit_port               => '5672',
      #  rabbit_userid             => 'guest',
      #  rabbit_password           => 'guest',
      #  rabbit_virtual_host       => '/',
        # General
      #  image_service             => 'nova.image.glance.GlanceImageService',
      #  glance_api_servers        => 'localhost:9292',
      #  instances_path            => 'C:\OpenStack\instances',
      #  mkisofs_cmd               => undef,
      #  qemu_img_cmd              => undef,
      #  auth_strategy             => 'keystone',
      #  # Live Migration
      #  live_migration            => false,
      #  live_migration_type       => 'Kerberos',
      #  live_migration_networks   => undef,
        # Virtual Switch
      #  virtual_switch_name       => 'br100',
      #  virtual_switch_address    => $::ipaddress_ethernet_2,
      #  virtual_switch_os_managed => true,
      #  # Others
      #  purge_nova_config         => true,
      #  verbose                   => false,
      #  debug                     => false
      #}
      
      class{'windows_sensu':
        rabbitmq_password        => 'sensu',
        rabbitmq_host            => "10.21.7.4",
        client_address           => $::ipaddress_ethernet_3,
        #rabbitmq_ssl_cert_chain  => '/etc/sensu/ssl/cert.pem',
        #rabbitmq_ssl_private_key => '/etc/sensu/ssl/key.pem',
      }

      #$sensu_version = '0.12.5-1'
      #windows_common::remote_file{'sensu_agent_download':
      #  source      => "http://repos.sensuapp.org/msi/sensu-${sensu_version}.msi",
      #  destination => 'c:/sensu_agent.msi',
      #}
      #exec{'install_sensu_agent':
      #  command     => 'cmd /c "c:\\sensu_agent.msi /passive"',
      #  subscribe   => Windows_common::Remote_file['sensu_agent_download'],
      #  refreshonly => true,
      #  path        => $::path,
      #}

      #file{'c:/etc': ensure => directory, }
      #file{'c:/etc/sensu': ensure => directory, }
      #file{'c:/etc/sensu/ssl': ensure => directory, }
#      file{'c:/etc/sensu/ssl/client': ensure => directory, }

      # ensure ordering
      #File['c:/etc'] -> File['c:/etc/sensu'] -> File['c:/etc/sensu/ssl']
# -> File['c:/etc/sensu/ssl/client']

#      file{'c:/etc': ensure => directory, }
#      class{'sensu':
#        version                  => 'present',
#        install_repo             => false,
#        rabbitmq_password        => 'sensu',
#        rabbitmq_host            => 'sauron.openstack.tld',
#        rabbitmq_ssl_cert_chain  => '/etc/sensu/ssl/cert.pem',
#        rabbitmq_ssl_private_key => '/etc/sensu/ssl/key.pem',
#        require                  => File['c:/etc/sensu/ssl'],
#      }
          

    }
    'RedHat':{
      class{'basenode':}
      class{'sensu_server::client':}
      class{'dell_openmanage':}
      class{'dell_openmanage::firmware::update':}
      class {'packstack':
        openstack_release => 'havana',
        controller_host   => $ipaddress,
        network_host      => $ipaddress,
        kvm_compute_host  => $ipaddress,
      }

    }
    'Debian':{
      notify {"${fqdn} is an openstack controller":}
      class{'basenode':} 
      class{'sensu_server::client':}
#      class {'rabbitmq':
#        delete_guest_user => true,
#        default_user => '',
#        default_pass => '',
#       ssl               => true,
#       ssl_cacert        => '/etc/rabbitmq/ssl/cacert.pem',
#       ssl_cert          => '/etc/rabbitmq/ssl/cert.pem',
#       ssl_key           => '/etc/rabbitmq/ssl/key.pem',
#      }

#      rabbitmq_user{'openstack':
#        admin => true,
#        password => 'openstack',
#      }
#      rabbitmq_vhost{'openstack':
#        ensure => present,
#      }
#      class {'::mysql::server':}

#      mysql::db {'keystone':
#        user     => 'keystone',
#        password => 'keystone',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }
#      mysql::db {'glance':
#        user     => 'glance',
#        password => 'glance',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }
#      mysql::db {'nova':
#        user     => 'nova',
#        password => 'nova',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }
#      mysql::db {'cinder':
#        user     => 'cinder',
#        password => 'cinder',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }
#      mysql::db {'ceilometer':
#        user     => 'ceilometer',
#        password => 'ceilometer',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }
#      mysql::db {'heat':
#        user     => 'heat',
#        password => 'heat',
#        host     => 'localhost',
#        grant    => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
#        require  => [Class['mysql::server']],
#      }

    }
    'Default':{
      notify {"${fqdn} isn't part of the sandbox":}
    }
  }
}
