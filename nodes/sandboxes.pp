node /sandbox0[1-9].*/{

  case $osfamily {
    'Windows':{
      class {'windows_common':}
      class {'windows_common::configuration::disable_firewalls':}
      class {'windows_common::configuration::enable_auto_update':}
      class {'windows_common::configuration::ntp':}
      class {'mingw':}

      class { 'openstack_hyper_v':
        # Services
        nova_compute              => true,
        # Network
        network_manager           => 'nova.network.manager.FlatDHCPManager',
        # Rabbit
        rabbit_hosts              => false,
        rabbit_host               => 'localhost',
        rabbit_port               => '5672',
        rabbit_userid             => 'guest',
        rabbit_password           => 'guest',
        rabbit_virtual_host       => '/',
        # General
        image_service             => 'nova.image.glance.GlanceImageService',
        glance_api_servers        => 'localhost:9292',
        instances_path            => 'C:\OpenStack\instances',
        mkisofs_cmd               => undef,
        qemu_img_cmd              => undef,
        auth_strategy             => 'keystone',
        # Live Migration
        live_migration            => false,
        live_migration_type       => 'Kerberos',
        live_migration_networks   => undef,
        # Virtual Switch
        virtual_switch_name       => 'br100',
        virtual_switch_address    => $::ipaddress_ethernet_2,
        virtual_switch_os_managed => true,
        # Others
        purge_nova_config         => true,
        verbose                   => false,
        debug                     => false
      }
      
      windows_common::remote_file{'sensu_agent_download':
        source      => 'http://repos.sensuapp.org/msi/sensu-0.12.5-1.msi',
        destination => 'c:/sensu_agent.msi',
      }

    }
    'RedHat':{
      class{'basenode':}
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
