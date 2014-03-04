node /^hv-compute[0-9]+\.openstack\.tld$/{
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

      class {'windows_git': before => Class['cloudbase_prep'],}
      class {'cloudbase_prep': }
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

# Limit production nodes to explicitly defined machines.
node 'hv-compute01.openstack.tld',
     'hv-compute02.openstack.tld',
     'hv-compute03.openstack.tld',
     'hv-compute04.openstack.tld',
     'hv-compute05.openstack.tld',
     'hv-compute06.openstack.tld',
     'hv-compute07.openstack.tld',
     'hv-compute08.openstack.tld',
     'hv-compute09.openstack.tld',
     'hv-compute10.openstack.tld',
     'hv-compute11.openstack.tld',
     'hv-compute12.openstack.tld',
     'hv-compute13.openstack.tld',
     'hv-compute14.openstack.tld',
     'hv-compute15.openstack.tld',
     'hv-compute16.openstack.tld',
     'hv-compute17.openstack.tld',
     'hv-compute18.openstack.tld',
     'hv-compute19.openstack.tld',
     'hv-compute20.openstack.tld',
     'hv-compute21.openstack.tld',
     'hv-compute22.openstack.tld',
     'hv-compute23.openstack.tld',
     'hv-compute26.openstack.tld',
     'hv-compute27.openstack.tld',
     'hv-compute30.openstack.tld',
     'hv-compute31.openstack.tld',
     
     'hv-compute101.openstack.tld',
     'hv-compute102.openstack.tld',
     'hv-compute103.openstack.tld',
     'hv-compute104.openstack.tld',
     'hv-compute107.openstack.tld',
     'hv-compute108.openstack.tld',
     'hv-compute110.openstack.tld',
     'hv-compute111.openstack.tld',
     'hv-compute115.openstack.tld',
     'hv-compute118.openstack.tld',
     
     'hv-compute117.openstack.tld',
     'hv-compute119.openstack.tld',
     'hv-compute120.openstack.tld',
     'hv-compute122.openstack.tld',
     'hv-compute123.openstack.tld',
     'hv-compute124.openstack.tld',
     'hv-compute125.openstack.tld',
     'hv-compute126.openstack.tld',
     'hv-compute127.openstack.tld',
     'hv-compute128.openstack.tld',
     'hv-compute129.openstack.tld',
     'hv-compute132.openstack.tld',
     'hv-compute134.openstack.tld',
     'hv-compute135.openstack.tld',
     'hv-compute136.openstack.tld',
     'hv-compute137.openstack.tld',
     'hv-compute138.openstack.tld',
     'hv-compute139.openstack.tld'
{
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

      class {'windows_git': before => Class['cloudbase_prep'],}
      class {'cloudbase_prep': }
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
