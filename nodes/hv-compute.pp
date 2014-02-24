node /^hv-compute1[0-9][0-9]\.openstack\.tld$/{
  case $kernel {
    'Windows':{
      class {'windows_common':}
      class {'windows_common::configuration::disable_firewalls':}
      class {'windows_common::configuration::disable_auto_update':}
      class {'windows_common::configuration::ntp':
        before => Class['windows_openssl'],
      }
      class{'windows_sensu':
        rabbitmq_password        => 'sensu',
        rabbitmq_host            => "10.21.7.4",
      }
      class {'windows_common::configuration::rdp':}
      class {'windows_openssl': }
      class {'java': distribution => 'jre' }

      virtual_switch { 'br100':
        notes             => 'Switch bound to main address fact',
        type              => 'External',
        os_managed        => true,
        interface_address => '10.0.2.*',
      }

      class {'windows_git': before => [Class['cloudbase_prep'],Class['openstack_hyper_v::nova_dependencies']],}
      class {'openstack_hyper_v::nova_dependencies':}
      class {'cloudbase_prep': require => Class['openstack_hyper_v::nova_dependencies'],}
      class {'jenkins::slave':
        install_java      => false,
        require           => [Class['java'],Class['cloudbase_prep']],
        manage_slave_user => false,
        executors         => 1,
        labels            => 'test',
        masterurl         => 'http://sandbox01.openstack.tld:8080',
      }
    }
    default:{
      notify{"${kernel} on ${fqdn} doesn't belong here":}
    }
  }

}
node /^hv-compute[0-9][0-9]\.openstack\.tld$/{
  case $kernel {
    'Windows':{
      class {'windows_common':}
      class {'windows_common::configuration::disable_firewalls':}
      class {'windows_common::configuration::disable_auto_update':}
      class {'windows_common::configuration::ntp':
        before => Class['windows_openssl'],
      }
      class{'windows_sensu':
        rabbitmq_password        => 'sensu',
        rabbitmq_host            => "10.21.7.4",
      }
      class {'windows_common::configuration::rdp':}
      class {'windows_openssl': }
      class {'java': distribution => 'jre' }

      virtual_switch { 'br100':
        notes             => 'Switch bound to main address fact',
        type              => 'External',
        os_managed        => true,
        interface_address => '10.0.2.*',
      }

      class {'windows_git': before => [Class['cloudbase_prep'],Class['openstack_hyper_v::nova_dependencies']],}
      class {'openstack_hyper_v::nova_dependencies':}
      class {'cloudbase_prep': require => Class['openstack_hyper_v::nova_dependencies'],}
      case $hostname {
        'hv-compute28','hv-compute29','hv-compute32','hv-compute38':{
           class {'jenkins::slave': 
             install_java      => false,
             require           => [Class['java'],Class['cloudbase_prep']],
             manage_slave_user => false,
             executors         => 1,
             labels            => '',
             masterurl         => 'http://jenkins.openstack.tld:8080',
           }  
        }
        default:{
          class {'jenkins::slave': 
            install_java      => false,
            require           => [Class['java'],Class['cloudbase_prep']],
            manage_slave_user => false,
            executors         => 1,
            labels            => 'hyper-v',
            masterurl         => 'http://jenkins.openstack.tld:8080',
          }
        }
      }
    }
    'Linux':{
       notify{"${kernel} on ${fqdn} is running Linux":}
      class{'dell_openmanage':}
      class{'dell_openmanage::firmware::update':}
    }
    default:{
      notify{"${kernel} on ${fqdn} doesn't belong here":}
    }
  }
}
