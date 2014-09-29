#
node /^hv-compute[0-9]+\.openstack\.tld$/{
  case $kernel {
    'Windows':{
      File {
        source_permissions => ignore,
      }

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

      class {'windows_freerdp': }

      class {'windows_git': before => Class['cloudbase_prep'],}
      class {'cloudbase_prep': }
      class {'jenkins::slave':
        install_java      => false,
        require           => [Class['java'],Class['cloudbase_prep']],
        manage_slave_user => false,
        executors         => 1,
        labels            => 'hv-staging',
        masterurl         => 'http://jenkins.openstack.tld:8080',
      }
      class{'sensu_client_plugins': require => Class['windows_sensu'],}
      if !defined (Windows_python::Dependency['PyYAML']){
        windows_python::dependency{ 'PyYAML':
          type    => pip,
          require => Class['cloudbase_prep'],
        }
      }

#      $q_ip = '10.21.7.22'
#      $nfs_location = "\\\\${q_ip}\\nfs"
#      file { "${nfs_location}":
#        ensure => directory,
#      }
#      file { "${nfs_location}\\facter":
#        ensure => directory,
#        require => File["$nfs_location"],
#      }
#      exec {"${hostname}-facter":
#        command => "\"C:\\Program Files (x86)\\Puppet Labs\\Puppet\\bin\\facter.bat\" -py > C:\\ProgramData\\facter.yaml",
#      }
#      file { "${nfs_location}\\facter\\${hostname}.yaml":
#        ensure  => file,
#        source  => 'C:\ProgramData\facter.yaml',
#        require => File["${nfs_location}\\facter"],
#        subscribe => Exec["${hostname}-facter"],
#      }

    }
    default:{
      notify{"${kernel} on ${fqdn} doesn't belong here":}
    }
  }

}

# Limit production nodes to explicitly defined machines.
node 
#     'hv-compute04.openstack.tld', ## reassigned to KVM -> c1-r1-u11
     'c1-r1-u09.openstack.tld',
#     'hv-compute06.openstack.tld', ## reassigned to KVM -> c1-r1-u07
     'c1-r1-u05.openstack.tld',
     'c1-r1-u03.openstack.tld',
#     'hv-compute09.openstack.tld',
     'c1-r2-u27.openstack.tld',
     'c1-r2-u26.openstack.tld',
     'c1-r2-u25.openstack.tld',
     'c1-r2-u24.openstack.tld',
     'c1-r2-u23.openstack.tld',
     'c1-r2-u22.openstack.tld',
     'c1-r2-u21.openstack.tld',
     'c1-r2-u20.openstack.tld',
     'c1-r2-u19.openstack.tld',
     'c1-r2-u18.openstack.tld',
     'c1-r2-u17.openstack.tld',
     'c1-r2-u16.openstack.tld',
     'c1-r2-u15.openstack.tld',
     'c1-r2-u14.openstack.tld',
     'hv-compute26.openstack.tld',
     'hv-compute27.openstack.tld',
     'hv-compute30.openstack.tld',
     'hv-compute31.openstack.tld',
     'hv-compute33.openstack.tld',
     
     'c2-r1-u01.openstack.tld',
     'c2-r1-u02.openstack.tld',
     'c2-r1-u03.openstack.tld',
     'c2-r1-u04.openstack.tld',
     'c2-r1-u05.openstack.tld',
     'c2-r1-u06.openstack.tld',
     'c2-r1-u07.openstack.tld',
     'c2-r1-u08.openstack.tld',
     'c2-r1-u09.openstack.tld',
     'c2-r1-u10.openstack.tld',
     'c2-r1-u11.openstack.tld',
     'c2-r1-u12.openstack.tld',
     'c2-r1-u13.openstack.tld',
     'c2-r2-u02.openstack.tld',
     'c2-r2-u03.openstack.tld',
     'c2-r2-u06.openstack.tld',
#     'hv-compute100.openstack.tld', ## assigned as Hopper (ticket system)
     'hv-compute101.openstack.tld',
#     'hv-compute103.openstack.tld', ## assigned as build automation node
     'hv-compute104.openstack.tld',
#     'hv-compute105.openstack.tld', ## reassigned to KVM -> kvm-compute105
     'hv-compute106.openstack.tld',
     'hv-compute107.openstack.tld',
     'hv-compute108.openstack.tld',
#     'hv-compute109.openstack.tld', ## assigned as test Hopper (ticket system)
     'hv-compute110.openstack.tld',
#     'hv-compute111.openstack.tld', ## assigned as AD cluster node
#     'hv-compute112.openstack.tld', ## assigned as AD cluster node
#     'hv-compute113.openstack.tld', ## assigned as AD cluster node
#     'hv-compute114.openstack.tld',
     'hv-compute115.openstack.tld',
     'hv-compute116.openstack.tld',
     'hv-compute117.openstack.tld',
     'hv-compute118.openstack.tld',
     'hv-compute119.openstack.tld',
     'hv-compute120.openstack.tld',
#     'hv-compute121.openstack.tld',
     'hv-compute122.openstack.tld',
     'hv-compute123.openstack.tld',
     'hv-compute124.openstack.tld',
     'hv-compute125.openstack.tld',
     'hv-compute126.openstack.tld',
     'hv-compute127.openstack.tld',
     'hv-compute128.openstack.tld',
#     'hv-compute132.openstack.tld',
     'hv-compute137.openstack.tld',
     'hv-compute139.openstack.tld',
     'hv-compute140.openstack.tld',
#     'hv-compute143.openstack.tld',
     'hv-compute147.openstack.tld',
     'hv-compute149.openstack.tld',
     'hv-compute150.openstack.tld',
     'hv-compute151.openstack.tld',
     'hv-compute152.openstack.tld',
     'hv-compute153.openstack.tld',
     'hv-compute154.openstack.tld',
     'hv-compute155.openstack.tld',
     'hv-compute156.openstack.tld',
     'hv-compute157.openstack.tld',
     'hv-compute158.openstack.tld',
     'hv-compute160.openstack.tld',
     'hv-compute161.openstack.tld',
     'hv-compute162.openstack.tld',
     'hv-compute163.openstack.tld',
     'hv-compute164.openstack.tld',
     'hv-compute167.openstack.tld',
     'hv-compute168.openstack.tld',
     'hv-compute170.openstack.tld',

  # HV test nodes.  Special Jenkins label.
     'hv-compute136.openstack.tld',
     'hv-compute171.openstack.tld',
     'hv-compute172.openstack.tld'
{
  case $kernel {
    'Windows':{
      File {
        source_permissions => ignore,
      }

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
      class{'sensu_client_plugins': require => Class['windows_sensu'],}
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
      class {'windows_freerdp': }

      $jenkins_label = $hostname ? {
#                         'hv-compute136' => 'hv-test',
                         'c1-r1-u09' => 'hv-icehouse',
                         'c1-r1-u05' => 'hv-icehouse',
                         'c1-r1-u03' => 'hv-icehouse',
                         'c1-r2-u27' => 'hv-icehouse',
                         'c1-r2-u26' => 'hv-icehouse',
                         'c1-r2-u25' => 'hv-icehouse',
                         'c1-r2-u24' => 'hv-icehouse',
                         'c1-r2-u23' => 'hv-icehouse',
                         'c1-r2-u22' => 'hv-icehouse',
                         'c1-r2-u21' => 'hv-icehouse',
                         'c1-r2-u20' => 'hv-icehouse',
                         'c1-r2-u19' => 'hv-icehouse',
                         'c1-r2-u18' => 'hv-icehouse',
                         'c1-r2-u17' => 'hv-icehouse',
                         'c1-r2-u16' => 'hv-icehouse',
                         'c1-r2-u15' => 'hv-icehouse',
                         'c1-r2-u14' => 'hv-icehouse',
                         'c2-r1-u01' => 'hv-icehouse',
                         'c2-r1-u02' => 'hv-icehouse',
                         'c2-r1-u03' => 'hv-icehouse',
                         'c2-r1-u04' => 'hv-icehouse',
                         'c2-r1-u05' => 'hv-icehouse',
                         'c2-r1-u06' => 'hv-icehouse',
                         #'c2-r1-u07' => 'hv-icehouse',
                         'c2-r1-u11' => 'hv-icehouse',
                         'c2-r1-u12' => 'hv-icehouse',
                         'c2-r1-u13' => 'hv-icehouse',
                         'c2-r2-u02' => 'hv-icehouse',
                         'c2-r2-u03' => 'hv-icehouse',
                         'c2-r2-u06' => 'hv-icehouse',
                         'hv-compute26' => 'hv-icehouse',
                         'hv-compute27' => 'hv-icehouse',
                         'hv-compute30' => 'hv-icehouse',
                         'hv-compute31' => 'hv-icehouse',
                         'hv-compute33' => 'hv-icehouse',
                         'hv-compute171' => 'hv-icehouse',
                         'hv-compute172' => 'hv-icehouse',
                         default        => 'hyper-v',
                       }
      
      class {'jenkins::slave': 
        install_java      => false,
        require           => [Class['java'],Class['cloudbase_prep']],
        manage_slave_user => false,
        executors         => 1,
        labels            => $jenkins_label,
        masterurl         => 'http://jenkins.openstack.tld:8080',
      }

      $q_ip = '10.21.7.22'
      $nfs_location = "\\\\${q_ip}\\nfs"
      file { "${nfs_location}":
        ensure => directory,
      }
      file { "${nfs_location}\\facter":
        ensure => directory,
        require => File["$nfs_location"],
      }
      exec {"${hostname}-facter":
        command => "\"C:\\Program Files (x86)\\Puppet Labs\\Puppet\\bin\\facter.bat\" -py > C:\\ProgramData\\facter.yaml",
      }
      file { "${nfs_location}\\facter\\${hostname}.yaml":
        ensure  => file,
        source  => 'C:\ProgramData\facter.yaml',
        require => File["${nfs_location}\\facter"],
        subscribe => Exec["${hostname}-facter"],
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
