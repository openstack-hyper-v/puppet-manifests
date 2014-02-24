node /^(kvm-compute[0-9][0-9])\.openstack\.tld$/{
  class{'basenode':}  
  class{'dell_openmanage':}
  class{'sensu_server::client':}
#  class{'dell_openmanage::firmware::update':}
  class{'jenkins::slave':
    labels            => 'kvm',
    masterurl         => 'http://jenkins.openstack.tld:8080',
  }
  class {'packstack':
    openstack_release => 'havana',
    controller_host   => '10.21.7.41',
    network_host      => '10.21.7.42',
    kvm_compute_host  => '10.21.7.31,10.21.7.32,10.21.7.33,10.21.7.34,10.21.7.35,10.21.7.36,10.21.7.38',
  }
  case $hostname {
    'kvm-compute01','kvm-compute02','kvm-compute03','kvm-compute04','kvm-compute05','kvm-compute06':{ $data_interface = 'em2' }
    'kvm-compute07','kvm-compute08','kvm-compute09','kvm-compute10':{ $data_interface = 'eth1' }
    default: { notify {"This isn't for ${hostname}":}
    }
  }
  case $hostname {
    'kvm-compute08','kvm-compute09','kvm-compute10':{
       file {'/etc/nova':
       ensure  => directory,
       recurse => true,
       owner   => 'root',
       group   => 'root',
       mode    => '0755',
       source  => 'puppet:///extra_files/nova',
     }

     file_line {
      'vncserver_listen':
        path   => '/etc/nova/nova.conf',
        match  => 'vncserver_listen=10\.21\.7\.*',
        line   => "vncserver_listen=${ipaddress_eth0}",
        ensure => present,
        require => File['/etc/nova'],
     }
     
     file_line {
      'vncserver_proxyclient_address':
        path   => '/etc/nova/nova.conf',
        match  => 'vncserver_proxyclient_address=10\.21\.7\.*',
        line   => "vncserver_proxyclient_address=${ipaddress_eth0}",
        ensure => present,
        require => File['/etc/nova'],
     }

     file {'/etc/neutron':
       ensure  => directory,
       recurse => true,
       owner   => 'root',
       group   => 'root',
       mode    => '0755',
       source  => 'puppet:///extra_files/eth1-neutron/neutron',
     }
    }
     default: { notify {"This isn't for ${hostname}":}
    }
  }
  file {"/etc/sysconfig/network-scripts/ifcfg-${data_interface}":
    ensure => file,
    owner  => '0',
    group  => '0',
    mode   => '0644',
    source => "puppet:///modules/packstack/ifcfg-${data_interface}",
  }
#  case $hostname {
#    'kvm-compute08','kvm-compute09','kvm-compute10':{
#      package {['openstack-nova-compute',
#                'openstack-selinux',
#                'openstack-neutron-openvswitch',
#                'openstack-neutron-linuxbridge',
#                'python-slip',
#                'python-slip-dbus',
#                'libglade2',
#                'nagios-common',
#                'tuned',
#                'yum-plugin-priorities',
#                'system-config-firewall',
#                'telnet',
#                'nrpe',
#                'centos-release-xen',
#                'openstack-ceilometer-compute'] :
#
#        ensure => 'latest',
#      }
#      exec {'centos_release_xen_update':
#        command   => "/usr/bin/yum update -y --disablerepo=* --enablerepo=Xen4CentOS kernel",
#        logoutput => true,
#        timeout   => 0,
#      }
#    }
#    default:{
#      notify {"${fqdn} doesn't require this":}
#    }
#  }
}
