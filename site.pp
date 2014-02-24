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

  class {'jenkins::slave': 
    masterurl => 'http://jenkins.openstack.tld:8080',
  }
  class {'basenode::ipmitools':}
  class {'sensu_server::client':}
  # Set NTP
  class {'ntp':
    servers => ['bonehed.lcs.mit.edu'],
  }
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
  file{'/srv/install/sensu/':
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///extra_files/sensu',
  }

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
    file {'/etc/puppet/modules/openstack_project':
      ensure  => link,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      target  => '/opt/openstack-infra/config/modules/openstack_project',
      require => Vcsrepo['/opt/openstack-infra/config'],
    }
    file {'/etc/puppet/modules/ssh':
      ensure  => link,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      target  => '/opt/openstack-infra/config/modules/ssh',
      require => Vcsrepo['/opt/openstack-infra/config'],
    }
    file {'/etc/puppet/modules/recheckwatch':
      ensure  => link,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      target  => '/opt/openstack-infra/config/modules/recheckwatch',
      require => Vcsrepo['/opt/openstack-infra/config'],
    }
    file {'/etc/puppet/modules/sudoers':
      ensure  => link,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      target  => '/opt/openstack-infra/config/modules/sudoers',
      require => Vcsrepo['/opt/openstack-infra/config'],
    }
    file {'/etc/puppet/modules/exim':
      ensure  => link,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      target  => '/opt/openstack-infra/config/modules/exim',
      require => Vcsrepo['/opt/openstack-infra/config'],
    }
    file {'/etc/puppet/modules/snmpd':
      ensure  => link,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      target  => '/opt/openstack-infra/config/modules/snmpd',
      require => Vcsrepo['/opt/openstack-infra/config'],
    }
    file {'/etc/puppet/modules/iptables':
      ensure  => link,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      target  => '/opt/openstack-infra/config/modules/iptables',
      require => Vcsrepo['/opt/openstack-infra/config'],
    }
    file {'/etc/puppet/modules/unattended_upgrades':
      ensure  => link,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      target  => '/opt/openstack-infra/config/modules/unattended_upgrades',
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
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-23-ae-fc-37-a4',]:
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

# Hyper-V compute Nodes, First 9 records for Rack1, Next 14 for Rack2

# Begin Rack 1
   file { [
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-d4-85-64-44-02-94',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-c8-8a',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-d8-a2',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-6d-dc',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-fd-c6',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-6d-cc',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-3c-4a-92-db-0e-2c',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-68-b5-99-c8-dc-1c',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-68-b5-99-c8-ed-e6']:
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => "puppet:///extra_files/winpe.pxe",
      require => Class['quartermaster'],
  }

# Begin Rack 2
   file { [
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-9e-82',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-8a-9b',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-88-cd',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-a3-b3',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-90-e9',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-90-d4',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-73-40',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-9f-6c',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-92-4f',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-92-5e',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-9e-46',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-8d-c5',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-90-1d',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-91-ec']:
      ensure  => absent,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => "puppet:///extra_files/winpe.pxe",
      require => Class['quartermaster'],
  }
# End Rack 2

# Begin Rack 3
   file { [
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-bb-91-1c',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-35-ad',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-22-19-27-10-e7',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-44-cb-0a',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-22-19-27-0f-51',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d3-43-95',
# hv-compute29
#    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d3-72-bc',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-34-36',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-35-8a',
#    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-35-9e',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-34-3b',
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-35-c3']:
# hv-compute38
#   '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-34-2c']:
      ensure  => absent,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => "puppet:///extra_files/winpe.pxe",
      require => Class['quartermaster'],
  }
  
  file { [
    # kvm-compute08
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-33-e1',
    # kvm-compute09
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-1e-c9-d0-35-ee',
    # kvm-compute10
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-22-19-27-0f-33',]:
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => "puppet:///extra_files/packstack-dell.eth0.pxe",
      require => Class['quartermaster'],
  }
  file { [
    # sandbox01
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-18-8b-f8-bb-b7',
    # sandbox02
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-18-8b-f8-75-5e',
    # sandbox03
    '/srv/tftpboot/pxelinux/pxelinux.cfg/01-00-18-8b-f8-c0-01']:
      ensure  => absent,
      owner   => root,
      group   => root,
      mode    => '0644',
      source  => "puppet:///extra_files/packstack-dell.eth0.pxe",
      require => Class['quartermaster'],
  }

# End Rack 3 

   file { [
    '/srv/install/microsoft/winpe/system/menu/d4-85-64-44-02-94.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-c8-8a.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-d8-a2.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-6d-dc.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-fd-c6.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-6d-cc.cmd',
    '/srv/install/microsoft/winpe/system/menu/3c-4a-92-db-0e-2c.cmd',
    '/srv/install/microsoft/winpe/system/menu/68-b5-99-c8-dc-1c.cmd',
    '/srv/install/microsoft/winpe/system/menu/68-b5-99-c8-ed-e6.cmd']:
     ensure  => present,
     owner   => root,
     group   => root,
     mode    => '0644',
     content => 'o:\hyper-v\2012r2\amd64\setup.exe /unattend:\\10.21.7.22\os\hyper-v\2012r2\unattend\hyper-v-2012r2-amd64.xml',
     require => Class['quartermaster'],
  }
# End Rack1
# Begin Rack2
   file { [
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-9e-82.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-8a-9b.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-88-cd.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-a3-b3.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-90-e9.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-90-d4.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-73-40.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-9f-6c.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-92-4f.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-92-5e.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-9e-46.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-8d-c5.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-90-1d.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-91-ec.cmd']:
     ensure  => present,
     owner   => root,
     group   => root,
     mode    => '0644',
     content => 'o:\hyper-v\2012r2\amd64\setup.exe /unattend:\\10.21.7.22\os\hyper-v\2012r2\unattend\hyper-v-2012r2-amd64.xml',
     require => Class['quartermaster'],
  }
# End Rack2
# Begin Rack3
   file { [
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-bb-91-1c.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-35-ad.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-22-19-27-10-e7.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-44-cb-0a.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-22-19-27-0f-51.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d3-43-95.cmd',
# hv-compute29
#    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d3-72-bc.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-34-36.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-35-8a.cmd',
# hv-compute32
#    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-35-9e.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-34-3b.cmd',
    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-35-c3.cmd']:
# hv-compute38
#    '/srv/install/microsoft/winpe/system/menu/00-1e-c9-d0-34-2c.cmd']:
     ensure  => present,
     owner   => root,
     group   => root,
     mode    => '0644',
     content => 'o:\hyper-v\2012r2\amd64\setup.exe /unattend:\\10.21.7.22\os\hyper-v\2012r2\unattend\hyper-v-2012r2-amd64.xml',
     require => Class['quartermaster'],
  }
  file { [
   # Sandbox01 
    '/srv/install/microsoft/winpe/system/menu/00-18-8b-f8-bb-b7.cmd',
   # Sandbox02
    '/srv/install/microsoft/winpe/system/menu/00-18-8b-f8-75-5e.cmd',
   # Sandbox03 
    '/srv/install/microsoft/winpe/system/menu/00-18-8b-f8-c0-01.cmd']:
     ensure  => present,
     owner   => root,
     group   => root,
     mode    => '0644',
     content => 'o:\hyper-v\2012r2\amd64\setup.exe /unattend:\\10.21.7.22\os\hyper-v\2012r2\unattend\hyper-v-2012r2-amd64.xml',
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
  # Set NTP
  class {'ntp':
    servers => ['bonehed.lcs.mit.edu'],
  }
  class {'basenode::ipmitools':}
  class {'sensu_server::client':}
    include jenkins
    jenkins::plugin {
      'swarm': ;
      'git':   ;
      'credentials':   ;
#     'svn':   ;
#     'ssh-auth':   ;
#     'pam-auth':   ;
      'ldap':   ;
      'ssh-slaves':   ;
      'stackhammer':   ;
      'devstack':   ;
      'nodelabelparameter': ;
#      'JClouds':   ;
      'parameterized-trigger': ;

      #Additional plugins as identified by previous use
      'externalresource-dispatcher': ;
      'gearman-plugin': ;
      'git-client': ;
      'github-api': ;
      'github': ;
      'postbuild-task': ;
      'powershell': ;
      'jquery': ;
      'logging': ;
      'metadata': ;
      'python': ;
      'scm-api': ;
      'timestamper': ;
      'token-macro': ;

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
    owner   => 'jenkins',
  }

  file { "${jenkinsconfig_path}users":
    ensure  => directory,
    source  => "puppet:///extra_files/jenkins/users",
    recurse => remote,
    replace => false,
    purge   => false,
    owner   => 'jenkins',
  }

}

node /^git.*/{
#  include classes/git_server
  class {'basenode':}
  class {'sensu_server::client':}
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
node /vpn.*/ {
#  class {'basenode':}
#  class {'basenode::dhcp2static':}
  class {'sensu_server::client':}

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
  openvpn::client {'vbud':
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
# class {'zuul':}
  class {'basenode':}
  class {'sensu_server::client':}
#  class { 'openstack_project::zuul_prod':
#    jenkins_server       => 'http://jenkins.openstack.tld:8080',
#    jenkins_user         => 'zuul',
#    jenkins_apikey       => 'a681364e086d19bf130207db042ff7a5',
#    gerrit_server        => 'review.openstack.org',
#    gerrit_user          => 'hyper-v-ci',
#    zuul_ssh_private_key => '/home/zuul/.ssh/id_rsa',
#    url_pattern          => 'http://logs.openstack.org/{build.parameters[LOG_PATH]}',
#    zuul_url             => 'http://zuul.openstack.tld/p',
#    sysadmins            => hiera('sysadmins'),
#    statsd_host          => 'graphite.openstack.org',
#    gearman_workers      => ['jenkins.openstack.tld'],
#  }
#  file { '/etc/cron.daily/rotate_zuul':
#    ensure  => file,
#    owner   => root,
#    group   => root,
#    mode    => 0755,
#    source  => "puppet:///modules/openstack_project/zuul/rotate_zuul",
#  }

notify {"${hostname} we're manually managing for now":}
}
node /hawk.*/ {
  class {'basenode':}
  class {'jenkins::slave':
    masterurl => 'http://jenkins.openstack.tld:8080',
  }
  class {'sensu_server::client':}
  class {'iphawk':}
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

node /sauron.*/{ 
  class{'basenode':}
  class{'sensu_server':}
}

import 'nodes/log_host.pp'


import 'nodes/hv-compute.pp'
import 'nodes/kvm-compute.pp'
import 'nodes/sandboxes.pp'
import 'nodes/packstack_nodes.pp'

import 'nodes/switches.pp'

