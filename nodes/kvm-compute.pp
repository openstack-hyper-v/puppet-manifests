node 'kvm-compute01.openstack.tld',
     'kvm-compute02.openstack.tld',
     'kvm-compute03.openstack.tld',
     'kvm-compute04.openstack.tld',
     'kvm-compute05.openstack.tld',
     'kvm-compute06.openstack.tld',
     'kvm-compute07.openstack.tld',
     'kvm-compute08.openstack.tld',
     'kvm-compute09.openstack.tld',
     'kvm-compute10.openstack.tld',
     'kvm-compute11.openstack.tld',
     'kvm-compute12.openstack.tld',
     'kvm-compute105.openstack.tld',
     'c1-r1-u07',
     'c1-r1-u11',
     'c1-r1-u17',
     'c1-r1-u15',
     'c1-r1-u13',
     'eth0-c2-r3-u03',
     'eth0-c2-r3-u08',
     'eth0-c2-r3-u20',
     'eth0-c2-r3-u21',
     'eth0-c2-r3-u22',
     'eth0-c2-r3-u23',
#     'eth0-c2-r3-u25', ## possible reassignment as Hopper
#     'eth0-c2-r3-u27', ## possible reassignment as Hopper
     'eth0-c2-r3-u39',
     'eth0-c2-r3-u40'
{
  class{'basenode':}  
  #class{'dell_openmanage':}
  case $bios_vendor {
    'Dell Inc.':{
          class{'dell_openmanage':}
     }
    default: { notify{"You're not Dell":}}

  }

  class{'sensu':}
  class{'sensu_client_plugins': require => Class['sensu'],}
#  class{'dell_openmanage::firmware::update':}
  class{'jenkins::slave':
    labels            => 'kvm',
    masterurl         => 'http://jenkins.openstack.tld:8080',
  }
  class {'packstack':
    openstack_release => 'havana',
    controller_host   => '10.21.7.41',
    network_host      => '10.21.7.42',
    kvm_compute_host  => "${ipaddress}",
  }
  case $hostname {
    'kvm-compute01',
    'kvm-compute02',
    'kvm-compute03',
    'kvm-compute04',
    'kvm-compute05',
    'kvm-compute06':
        { $data_interface = 'em2' }
    default: 
#    'kvm-compute07',
#    'kvm-compute08',
#    'kvm-compute09',
#    'kvm-compute10',
#    'kvm-compute11':
        { $data_interface = 'eth1' }
#    default: 
#        { notify {"This isn't for ${hostname}":}
#    }
  }
  case $hostname {
    'kvm-compute01',
    'kvm-compute02',
    'kvm-compute03',
    'kvm-compute04',
    'kvm-compute05',
    'kvm-compute06',
    'kvm-compute07': {}

    default: {
#    'kvm-compute08',
#    'kvm-compute09',
#    'kvm-compute10',
#    'kvm-compute11':{
       file {'/etc/nova':
       ensure  => directory,
       recurse => true,
       owner   => 'root',
       group   => 'root',
       mode    => '0755',
       source  => 'puppet:///extra_files/nova',
#      before  => Ini_setting['reserved_host_disk_mb', 'disk_allocation_ratio'],
     }

     ini_setting {
      'vncserver_listen':
        path   => '/etc/nova/nova.conf',
        section => 'DEFAULT',
        setting => 'vncserver_listen',
        value   => "${ipaddress_eth0}",
        ensure => present,
        require => File['/etc/nova'],
     }
     
     ini_setting {
      'vncserver_proxyclient_address':
        path   => '/etc/nova/nova.conf',
        section => 'DEFAULT',
        setting => 'vncserver_proxyclient_address',
        value   => "${ipaddress_eth0}",
        ensure => present,
        require => File['/etc/nova'],
     }

     file {'/etc/neutron':
       ensure  => directory,
       recurse => true,
       owner   => 'root',
       group   => 'root',
       mode    => '0755',
       source  => "puppet:///extra_files/${data_interface}-neutron/neutron",
     }
    }
#     default: { 
#       #notify {"This isn't for ${hostname}":}
#    }
  }
#  ini_setting {
#   'reserved_host_disk_mb':
#     path   => '/etc/nova/nova.conf',
#     section => 'DEFAULT',
#     setting => 'reserved_host_disk_mb',
#     value   => "512",
#     ensure => present,
#  }
#  ini_setting {
#   'disk_allocation_ratio':
#     path   => '/etc/nova/nova.conf',
#     section => 'DEFAULT',
#     setting => 'disk_allocation_ratio',
#     value   => "0.9",
#     ensure => present,
#  }
     
  file {"/etc/sysconfig/network-scripts/ifcfg-${data_interface}":
    ensure => file,
    owner  => '0',
    group  => '0',
    mode   => '0644',
    source => "puppet:///modules/packstack/ifcfg-${data_interface}",
  }
  package {['openstack-nova-compute',
            'openstack-selinux',
            'openstack-neutron-openvswitch',
            'openstack-neutron-linuxbridge',
            'python-slip',
            'python-slip-dbus',
            'libglade2',
            'nagios-common',
            'tuned',
            'yum-plugin-priorities',
            'system-config-firewall',
            'telnet',
            'nrpe',
            'centos-release-xen',
            'openstack-ceilometer-compute'] :

    ensure => 'present',
  }
#  exec {'centos_release_xen_update':
#    command   => "/usr/bin/yum update -y --disablerepo=* --enablerepo=Xen4CentOS kernel",
#    logoutput => true,
#    timeout   => 0,
#  }

# No longer going to ensure these via puppet.  Will instead monitor via Sensu to facilitate investigation, as these should never halt.
#  service {
#    'libvirtd',
#    'openvswitch',
#    'openstack-nova-compute',
#    'neutron-linuxbridge-agent':
#    ensure  => running,
#    require => [
#      File["/etc/sysconfig/network-scripts/ifcfg-${data_interface}"],
#      #Exec['centos_release_xen_update'],
#      Class['packstack'],
#      ],
#  }

}


node 
     'eth0-c2-r3-u06',
     'eth0-c2-r3-u11',
#     'eth0-c2-r3-u13',
#     'eth0-c2-r3-u14',
     'eth0-c2-r3-u16',
     'eth0-c2-r3-u28',
#     'eth0-c2-r3-u30',
     'eth0-c2-r3-u31',
     'eth0-c2-r3-u32',
     'eth0-c2-r3-u33',
#     '',
     'c1-r1-u09',
     'c1-r1-u05',
     'c1-r1-u03',
     'c1-r1-u01',
     /^(kvm-compute[0-9]+)/{
  class{'basenode':}  
  #class{'dell_openmanage':}
  case $bios_vendor {
    'Dell Inc.':{
          class{'dell_openmanage':}
     }
    default: { notify{"You're not Dell":}}

  }

  class{'sensu':}
  class{'sensu_client_plugins': require => Class['sensu'],}
#  class{'dell_openmanage::firmware::update':}
  class{'jenkins::slave':
    labels            => 'kvm',
    masterurl         => 'http://jenkins.openstack.tld:8080',
  }
  class {'packstack':
    openstack_release => 'havana',
    controller_host   => '10.21.7.41',
    network_host      => '10.21.7.42',
    kvm_compute_host  => "${ipaddress}",
  }
  $data_interface = 'eth1'
  file {'/etc/nova':
    ensure  => directory,
    recurse => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///extra_files/nova',
  }

  ini_setting {
   'vncserver_listen':
     path   => '/etc/nova/nova.conf',
     section => 'DEFAULT',
     setting => 'vncserver_listen',
     value   => "${ipaddress_eth0}",
     ensure => present,
     require => File['/etc/nova'],
  }
     
  ini_setting {
   'vncserver_proxyclient_address':
     path   => '/etc/nova/nova.conf',
     section => 'DEFAULT',
     setting => 'vncserver_proxyclient_address',
     value   => "${ipaddress_eth0}",
     ensure => present,
     require => File['/etc/nova'],
  }

  file {'/etc/neutron':
    ensure  => directory,
    recurse => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => "puppet:///extra_files/${data_interface}-neutron/neutron",
  }

  file {"/etc/sysconfig/network-scripts/ifcfg-${data_interface}":
    ensure => file,
    owner  => '0',
    group  => '0',
    mode   => '0644',
    source => "puppet:///modules/packstack/ifcfg-${data_interface}",
  }
  package {[
            'openstack-selinux',
            'openstack-neutron-openvswitch',
            'openstack-neutron-linuxbridge',
            'python-slip',
            'python-slip-dbus',
            'libglade2',
            'nagios-common',
            'tuned',
            'yum-plugin-priorities',
            'system-config-firewall',
            'telnet',
            'nrpe',
            'centos-release-xen',
            'openstack-ceilometer-compute'] :

    ensure => 'present',
  }
  package {'openstack-nova-compute':
    ensure => '2013.2.3-1.el6',
  }

  service { 'network':
     ensure   =>  running,
     subscribe => File["/etc/sysconfig/network-scripts/ifcfg-${data_interface}"],
  }
 
# No longer going to ensure these via puppet.  Will instead monitor via Sensu to facilitate investigation, as these should never halt.
  service {
    ['libvirtd',
    'openvswitch',
    'openstack-nova-compute',
    'neutron-linuxbridge-agent']:
    ensure  => stopped,
    require => [
      File["/etc/sysconfig/network-scripts/ifcfg-${data_interface}"],
      #Exec['centos_release_xen_update'],
      Class['packstack'],
      ],
  }

}
