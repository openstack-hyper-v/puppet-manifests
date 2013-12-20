 # case $kernel {
 #   'Windows':{
 #     Jenkins::Slave{
 #       install_java       => false,
 #       manage_slave_user => false, 
 #      }
 #   }
 #   default: { notify {"${kernel} does not require this":}
 #   }
 # }


node default {
# Need to enable stored configs to use this
#  @@quartermaster::pxe::file {$macaddress: $arp_type, $host_macaddress,}
#  include 'hardware/dell'

  # This gets applied to everything
  case $kernel {
   'Linux':{
     notify {"supported kernel ${kernel} in our infrastructure":}
     @@quartermaster::pxe::file {$macaddress: arp_type => $arp_type, host_macaddress => $host_macaddress,}
   }
   'Windows':{ notify {"supported kernel ${kernel} in our infrastructure":} }
   default:{ notify {"unsupported kernel ${kernel}":} }
  }
}


node /node[0-1].openstack.tld/ {
  class {'basenode':}
  class {'dell_openmanage':}
#  class {'dell_openmanage::repository':}
#  class {'dell_openmanage::firmware::update':}
}

node /^(norman|mother|ns[0-9\.]+)/ {
  class { 'ipam': }
}

node /quartermaster.*/ {
  Quartermaster::Pxe::File <<||>>
#node /(q0|q1).*/ {
  class {'jenkins::slave':}
  class {'basenode::ipmitools':}
  class {'quartermaster':}
  class {'network_mgmt':}

#  network_mgmt::switch{'c3560g04':
#    device_type     => 'cisco',
#    access_method   => 'telnet',
#    enable_password => 'hard24get',
#    username        => 'puppet',
#    user_password   => '$c1sc0',
#  }
#network_mgmt::port{'Gi0/13':
# port_type => default,
#}

# This provides the zuul and pip puppet modules that we use on our openstack work
    vcsrepo{'/opt/openstack-infra/config':
      ensure   => present,
      provider => git,
      source   => 'git://github.com/openstack-infra/config.git',
    }
    file {'/etc/puppet/modules/zuul':
      ensure  => link,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      target  => '/opt/openstack-infra/config/modules/zuul',
      require => Vcsrepo['/opt/openstack-infra/config'],
    }
    file {'/etc/puppet/modules/pip':
      ensure  => link,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      target  => '/opt/openstack-infra/config/modules/pip',
      require => Vcsrepo['/opt/openstack-infra/config'],
    }
    file {'/srv/install/kickstart':
      ensure  => directory,
      recurse => true,
      owner   => 'www-data',
      group   => 'www-data',
      mode    => '0644',
      source  => 'puppet:///extra_files/kickstart',
    }

# Packstack Controller and Neutron Node Pxe Files
   file { [ '/srv/tftpboot/pxelinux/pxelinux.cfg/01-d4-85-64-44-63-c6',
            '/srv/tftpboot/pxelinux/pxelinux.cfg/01-1c-c1-de-e8-9a-88']:
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
#     content => template('quartermaster/pxefile.erb'),
#      source  => "puppet:///extra_files/packstack.pxe",
      source  => "puppet:///extra_files/packstack-hp.pxe",
      require => Class['quartermaster'],
    }


# Packstack kvm node  Pxe Files
   file { [ 
## kvm-compute01
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-23-ae-fc-37-84',
## kvm-compute02
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-23-ae-fc-37-48',
## kvm-compute03
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-23-ae-fc-3f-08',
## kvm-compute04
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-22-19-d1-e8-dc',
## kvm-compute05
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-23-ae-fc-33-2c',
## kvm-compute06
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-23-ae-fc-37-a4']:
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
#     content => template('quartermaster/pxefile.erb'),
#      source  => "puppet:///extra_files/packstack.pxe",
      source  => "puppet:///extra_files/packstack-dell.em1.pxe",
#      source  => "puppet:///extra_files/packstack-dell.pxe",
      require => Class['quartermaster'],
   }
## kvm-compute07
# Interface is eth0 and not em1
# Currently supplying a different kickstart
   file { '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-18-8b-ff-ae-5a':
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
#     content => template('quartermaster/pxefile.erb'),
#      source  => "puppet:///extra_files/packstack.pxe",
      source  => "puppet:///extra_files/packstack-dell.eth0.pxe",
#      source  => "puppet:///extra_files/packstack-dell.pxe",
      require => Class['quartermaster'],
   }

# Hyper-V compute Nodes, First 9 records for Rack1
   file { [
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-d4-85-64-44-02-94',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-c8-8a',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-d8-a2',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-6d-dc',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-fd-c6',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-6d-cc',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-0e-2c',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-68-b5-99-c8-dc-1c',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-68-b5-99-c8-ed-e6',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-35-ad',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-22-19-27-10-e9',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-44-cb-0a',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-22-19-27-0f-51',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d3-43-97',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d3-72-bc',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-34-36',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-35-8a',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-35-9e',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-34-3b',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-35-c3',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-33-e1',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-35-ee',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-22-19-27-0f-33',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-34-2c']:
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
#     content => template('quartermaster/pxefile.erb'),
#      source  => "puppet:///extra_files/packstack.pxe",
      source  => "puppet:///extra_files/winpe.pxe",
      require => Class['quartermaster'],
  }
   file { [
    '/srv/install/microsoft/winpe/system/menu/d4-85-64-44-02-94.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-c8-8a.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-d8-a2.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-6d-dc.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-fd-c6.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-6d-cc.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-0e-2c.cmd',
    '/srv/install/microsoft/winpe/system/menu/68-b5-99-c8-dc-1c.cmd',
    '/srv/install/microsoft/winpe/system/menu/68-b5-99-c8-ed-e6.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-35-ad.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-22-19-27-10-e9.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-44-cb-0a.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-22-19-27-0f-51.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d3-43-97.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d3-72-bc.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-34-36.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-35-8a.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-35-9e.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-34-3b.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-35-c3.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-33-e1.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-35-ee.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-22-19-27-0f-33.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-34-2c.cmd']:
     ensure  => present,
#      ensure  => link,
      owner   => root,
      group   => root,
      mode    => '0644',
#     content => template('quartermaster/pxefile.erb'),
     content => 'o:\hyper-v\2012r2\amd64\setup.exe /unattend:\\10.21.7.22\os\hyper-v\2012r2\unattend\hyper-v-2012r2-amd64.xml',
#      target  => '/srv/install/microsoft/winpe/system/en_microsoft_hyper-v_server_2012_r2_x64_dvd_2708236.iso.cmd',
#     source  => "puppet:///extra_files/packstack.pxe",
#      source  => "puppet:///s/winpe.pxe",
      require => Class['quartermaster'],
  }
}



node /^(frankenstein).*/{
  $graphical_admin = ['blackbox',
                      'ipmitool',
                      'freeipmi-tools', 
                      'tightvncserver', 
                      'freerdp',
                      'freerdp-x11',
                      'ubuntu-virt-mgmt']
  package {$graphical_admin:
    ensure => latest,
  }
#apt::ppa { 'ppa:dotcloud/lxc-docker': }
  class {'basenode':}
  class {'apt':}
#  class {'jenkins::slave':}
  class {'docker':}
  docker::pull{'ubuntu':}
  docker::pull{'centos':}
}



# Jenkins
node /jenkins.*/ {
#    $ui_user = hiera('ui_user',{})
#    $ui_pass = hiera('ui_pass',{})
  class {'basenode::ipmitools':}
    include jenkins
    jenkins::plugin {
      'swarm': ;
      'git':   ;
      'credentials':   ;
     #'svn':   ;
#     'ssh-auth':   ;
#     'pam-auth':   ;
      'ldap':   ;
      'ssh-slaves':   ;
      'stackhammer':   ;
      'devstack':   ;
      'nodelabelparameter': ;
#      'JClouds':   ;
      'nodelabelparameter': ;
      'parameterized-trigger': ;

    }
# Build Tools

# FPM
# More Info: https://github.com/jordansissel/fpm
#
# Install fpm

  package {'fpm':
    ensure => installed,
    provider => 'gem',
  }

# Jenkins Job Builder
# Originating from Openstack-Infra
# Puppet module provided by Openstack-Hyper-V
  class {'jenkins_job_builder':}

# Initial security settings.  May be adjusted later.
  $jenkinsconfig_path = '/var/lib/jenkins/'
$  file { "${jenkinsconfig_path}config.xml":
$    ensure  => link,
$    target  => "${jenkinsconfig_path}users/config_base.xml",
$	require => File["${jenkinsconfig_path}users"],
$  }

  file { "${jenkinsconfig_path}users":
    ensure  => directory,
    source  => "puppet:///extra_files/jenkins/users",
    recurse => remote,
    replace => false,
    purge   => false,
  }

}

node /^git.*/{
#  include classes/git_server
  class {'gitlab_server': }
}
node /^(frodobaggins).*/{

#  require '::windows_common'

#  class {'windows_git':}
#  class {'windows_7zip':}
#  class {'windows_chrome':}
#  class {'windows_common':}
#  class {'windows_common::configuration::disable_firewalls':}
  #class {'windows_common::configuration::ntp':}
#  class {'windows_common::configuration::enable_auto_update':}
  class{'petools':}
  exec {'install-chocolatey':
    command  => "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))",
    provider => powershell,
  }

}
node /^(docker[0-9]).*/{
  class {'docker':}
  docker::pull{'base':}
  docker::pull{'centos':}
}
node /^(index.docker).*/{
  class {'docker::registry':}
}
node /(001ec*).*/ {
  class {'basenode':}
  class {'dell_openmanage':}
  class {'dell_openmanage::firmware::update':}
  class {'jenkins::slave':} 
}
#node /git.*/{
#include gitlab
#}
node /vpn.*/ {
#  class {'basenode':}
#  class {'basenode::dhcp2static':}

  package {'bridge-utils':
    ensure => latest,
  }
  openvpn::server{'hypervci':
    country      => 'US',
    province     => 'MA',
    city         => 'Cambridge',
    organization => 'opentack.tld',
    email        => 'root@openstack.tld',
#    dev          => 'tap0',
    local        => $::ipaddress_br0,
#    proto        => 'tcp',
    server       => '10.253.253.0 255.255.255.0',
    push         => [
#                     'route 10.21.7.0 255.255.255.0 10.253.353.1',
                     'redirect-gateway def1 bypass-dhcp',
                     'dhcp-option DNS 10.21.7.1',
                     'dhcp-option DNS 8.8.8.8',
                     'dhcp-option DNS 8.8.4.4',
#                     'topology subnet'
                    ],
#    push         => ['route 10.21.7.0 255.255.255.0'],
  }

  firewall { '100 snat for network openvpn':
    chain    => 'POSTROUTING',
    jump     => 'MASQUERADE',
    proto    => 'all',
    outiface => "eth0",
    source   => '10.253.253.0/24',
    table    => 'nat',
  }
  firewall {'200 INPUT allow DNS':
    action => accept,
    proto  => 'udp',
    sport  => 'domain'
  }

  openvpn::client {'ppouliot':
    server => 'hypervci',
    remote_host => '64.119.130.115',
  }
  openvpn::client {'nmeier':
    server => 'hypervci',
    remote_host => '64.119.130.115',
  }
  openvpn::client {'trogers':
    server => 'hypervci',
    remote_host => '64.119.130.115',
  }
  openvpn::client {'habdi':
    server => 'hypervci',
    remote_host => '64.119.130.115',
  }
  openvpn::client {'cloudbase':
    server => 'hypervci',
    remote_host => '64.119.130.115',
  }
  openvpn::client {'apilotti':
    server => 'hypervci',
    remote_host => '64.119.130.115',
  }
  openvpn::client {'gsamfira':
    server => 'hypervci',
    remote_host => '64.119.130.115',
  }
#  openvpn::client_specific_config {'ppouliot':
#  openvpn::client_specific_config {'ppouliot':
#  openvpn::client_specific_config {'ppouliot':
#    server   => 'hypervci',
#    ifconfig => '10.253.253.1 255.255.255.0',
#    route    => ['route 10.21.7.0 255.255.255.0 10.253.253.1',
#                'route 172.18.2.0 255.255.255.0 10.253.253.1'],
#    redirect_gateway => true,
#  }

  class {'quagga':
    ospfd_source => 'puppet:///extra_files/ospfd.conf',
  }
#  file {'/etc/quagga/zebra.conf':
#    ensure  => file,
#    owner   => 'quagga',
#    group   => 'quagga',
#    mode    => '0640',
#    source  => 'puppet:///extra_files/zebra.conf',
#    notify  => Service['zebra'],
#    require => Class['quagga'],
#    before  => Service['zebra'],
#  }
}

node /zuul.*/ {
  class {'zuul':}
}
node /ironic.*/{
  vcsrepo{'/usr/local/src/ironic':
    ensure   => present,
    source   => 'git://github.com/ppouliot/ironic.git',
    provider => git,
  }
  vcsrepo{'/opt/ironic':
    ensure   => present,
    source   => 'git://github.com/openstack/ironic.git',
    provider => git,
  }
}


#
# Begin Packstack nodes
##
node /^(kvm-compute[0-9][0-9]).*/{
  class{'basenode':}  
  class{'basenode::dhcp2static':}  
  class{'dell_openmanage':}
#  class{'dell_openmanage':firmware::udate':}
  class{'jenkins::slave': }
  class{'packstack::yumrepo':}

}
node /^(openstack-controller).*/{
  class{'basenode':}  
#  class{'basenode::dhcp2static':}  
  class{'jenkins::slave': }
  class {'packstack':
    openstack_release => 'havana',
    controller_host   => '10.21.7.41',
    network_host      => '10.21.7.42',
    kvm_compute_host  => '10.21.7.31,10.21.7.32,10.21.7.33,10.21.7.34,10.21.7.35,10.21.7.36,10.21.7.38',
  }

  vcsrepo {'/usr/local/src/openstack-imaging-tools':
    ensure   => present,
    provider => git,
    source   => 'git://github.com/cloudbase/windows-openstack-imaging-tools.git'
  }
  vcsrepo {'/usr/local/src/openstack-dev-scripts':
    ensure   => present,
    provider => git,
    source   => 'git://github.com/ppouliot/openstack-dev-scripts.git',
  }
  vcsrepo {'/usr/local/src/unattend-setup-scripts':
    ensure   => present,
    provider => git,
    source   => 'git://github.com/cloudbase/unattended-setup-scripts.git',
  }

}
node /^(neutron-controller).*/{
  class{'basenode':}  
#  class{'basenode::dhcp2static':}  
  class{'jenkins::slave': }
  class{'packstack::yumrepo':}  
}
# End Packstack nodes

node /^(hv-compute[0-9][0-9]).*/{
  notify {"Welcome ${fqdn}":}
  case $hostname {
    'hv-compute01':{
        class {'petools':}
     }
    default: { notify{"You're not hv-compute01":}}
    
  }
  class {'windows_common':}
  class {'windows_common::configuration::disable_firewalls':}
  class {'windows_common::configuration::enable_auto_update':}
  class {'windows_common::configuration::ntp':}
  class {'java': distribution => 'jre' }
  class {'jenkins::slave': 
    install_java => false,
    require      => Class['java'],
  }
  
  #class {'mingw':}
  #Class['mingw'] -> Class['openstack_hyper_v'] <| |> 
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
    #General
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
    virtual_switch_address    => $::ipaddress_ethernet_3,
    virtual_switch_os_managed => true,
    # Others
    purge_nova_config         => true,
    verbose                   => false,
    debug                     => false
  }
#  class {'hyper_v::tools::create_vm':
#  }

}

#node /00155d078800/ {
#  notify {"Welcome ${fqdn} you are devstack node":}
#  class {'devstack':
#    stackroot    => "/opt",
#    admin_passwd => "${operatingsystem}"
#  }
#}


#node /(devstack[0-1]).*/ {
#  notify {"Welcome ${fqdn} you are devstack node":}
#  class {'devstack':
#    stackroot    => "/opt",
#    admin_passwd => "${operatingsystem}"
#  }

#}
node /^(c3130g01).*/ {
  notify {"${hostname} is a switch":}
}
node /^(c3130g02).*/ {
  notify {"${hostname} is a switch":}
}

node /^(c3560g01).*/ {
  notify {"${hostname} is a switch":}
}
node /^(c3560g02).*/ {
  notify {"${hostname} is a switch":}
}
node /^(c3560g04).*/ {
  notify {"${hostname} is a switch":}
}
node /^(c3560g03).*/ {
  notify {"${hostname} is a switch":}
} 
