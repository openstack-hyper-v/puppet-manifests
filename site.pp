node /node[0-1].openstack.tld/ {
  class {'basenode':}
  class {'dell_openmanage':}
#  class {'dell_openmanage::repository':}
#  class {'dell_openmanage::firmware::update':}
}

node /^(norman|mother|ns[0-9\.]+)/ {
  class { 'ipam': }
}

#node /quartermaster.*/ {
node /q0.*/ {
  class {'jenkins::slave':}
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
  file { "${jenkinsconfig_path}config.xml":
    ensure  => link,
    target  => "${jenkinsconfig_path}users/config_base.xml",
	require => File["${jenkinsconfig_path}users"],
  }

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
node /^(hv-compute[0-9][0-9]).*/{
#  $path => $::path,
  #class{'petools':}
#  class{'windows_common::configuration::disable_firewalls':}
#  class{'windows_common::configuration::enable_auto_update':}
#  class{'windows_common::configuration::rdp':}
#  class{'windows_common::configuration::ntp':}
#  Package { provider => chocolatey }
#  package {'puppet': ensure => installed, }
#  package {'python.x86': ensure => installed, }
#  package {'easy.install': ensure => installed, }
#  package {'pip': ensure => installed, }
#  package {'mingw': ensure => installed, }
#  package {'chromium': ensure => installed, }
#  package {'java.jdk': ensure => installed, }
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
  
  class {'mingw':}
  
}
