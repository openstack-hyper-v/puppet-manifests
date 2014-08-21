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
     class {'basenode':}
   }
   'Windows':{
     notify {"supported kernel ${kernel} in our infrastructure":}
     class { 'windows_openssl': }
     class { 'cloudbase_prep::wsman': require => Class['windows_openssl'],}

     $q_ip = '10.21.7.22'
     $nfs_location = "\\\\${q_ip}\\nfs\\hosts"
     file { "$nfs_location":
       ensure => directory,
     }
     file { "$nfs_location\\${hostname}":
       ensure => directory,
       require => File["$nfs_location"],
     }
     exec {"${hostname}-facter":
       command => "\"C:\\Program Files (x86)\\Puppet Labs\\Puppet\\bin\\facter.bat\" -py > C:\\ProgramData\\facter.yaml",
     }
     file { "$nfs_location\\${hostname}\\facter.yaml":
       ensure  => file,
       source  => 'C:\ProgramData\facter.yaml',
       require => File["$nfs_location\\${hostname}"],
       subscribe => Exec["${hostname}-facter"],
     }
   }
   default:{ notify {"unsupported kernel ${kernel}":} }
  }
}

node /node[0-1].openstack.tld/ {
  class {'basenode':}
  class {'dell_openmanage':}
#  class {'dell_openmanage::repository':}
#  class {'dell_openmanage::firmware::update':}
  class {'sensu':}
  class {'sensu_client_plugins': require => Class['sensu'],}
}

node /^(norman|mother|ns[0-9\.]+)/ {
  include basenode::params
#  package {$nfs_packages:
#    ensure => latest,
#  }
#  create_resources(basenode::nfs_mounts,$nfs_mounts)
  class {'sensu':}
  class {'sensu_client_plugins': require => Class['sensu'],}
  class { 'ipam': }
}


node /^git.*/{
#  include classes/git_server
  class {'basenode':}
  class {'sensu':}
  class {'sensu_client_plugins': require => Class['sensu'],}
  class {'gitlab_server': }
}

node /^(docker[0-9]).*/{
  include basenode::params
  package {$nfs_packages:
    ensure => latest,
  }
  create_resources(basenode::nfs_mounts,$nfs_mounts)
  class {'docker':}
  docker::pull{'base':}
  docker::pull{'centos':}
  class {'sensu':}
  class {'sensu_client_plugins': require => Class['sensu'],}
}

node /^(index.docker).*/{
  include basenode::params
  package {$nfs_packages:
    ensure => latest,
  }
  create_resources(basenode::nfs_mounts,$nfs_mounts)
  class {'docker::registry':}
  class {'sensu':}
  class {'sensu_client_plugins': require => Class['sensu'],}
}

node /hawk.*/ {

  $ipmi_network         = hiera('ipmi_network',{})
  $ipmi_network_gateway = hiera('ipmi_network_gateway',{})

  class {'basenode':}
  class {'jenkins::slave':
    masterurl => 'http://jenkins.openstack.tld:8080',
  }
  class {'sensu':}
  class {'sensu_client_plugins': require => Class['sensu'],}

  class {'iphawk':}
  class { 'ipam': }

}


node /ironic.*/{
  include basenode::params
  package {$nfs_packages:
    ensure => latest,
  }
  create_resources(basenode::nfs_mounts,$nfs_mounts)
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
  class {'sensu':}
  class {'sensu_client_plugins': require => Class['sensu'],}
}

node /sauron.*/{ 
  class{'basenode':}
  class{'sensu_server':}
  class {'sensu_client_plugins': require => Class['sensu_server'],}
  package{'mailutils':
    ensure => present,
  }
}
node /001cc43cbe88.openstack.tld/{
  include basenode::params
  package {$nfs_packages:
    ensure => latest,
  }
  create_resources(basenode::nfs_mounts,$nfs_mounts)
#  class {'ipam':}
#
#  class{'sensu_server':}
#  class {'sensu_client_plugins': require => Class['sensu_server'],}
  class {'iphawk':}
#  class {'nginx':}
}

# Begin MySql Cluster
# Testing node definition
node /(001cc410b696.openstack.tld|001cc43c4dd6.openstack.tld|001cc474636c.openstack.tld)/{
  include basenode::params
  package {$nfs_packages:
    ensure => latest,
  }
  create_resources(basenode::nfs_mounts,$nfs_mounts)
#  class { 'mysql::server':
#    config_hash => { 'root_password' => 'example' }
#  }
  class { 'galera::server':
    config_hash => {
     'root_password' => 'ChangeMe',
    },
    cluster_name => 'galera_cluster',
    master_ip => false,
    wsrep_sst_username => 'ChangeMe',
    wsrep_sst_password => 'ChangeMe',
    wsrep_sst_method => 'rsync',
 }

}
# End MySql Cluster

#Begin Memcached

node /eth0-c2-r3-u34.mgmt.colo3.openstack.tld/{
  class {'basenode':}
#  package {$nfs_packages:
#    ensure => latest,
#  }
#  create_resources(basenode::nfs_mounts,$nfs_mounts)
  class { 'memcached': }
}

node /(ad0.openstack.tld|ad1.openstack.tld|ad2.openstack.tld){
  notify {'celso is awesome and is going to build us':}
}

import 'nodes/log_host.pp'
import 'nodes/quartermaster.pp'
import 'nodes/jenkins.pp'
import 'nodes/vpn.pp'
import 'nodes/frankenstein.pp'
import 'nodes/zuul.pp'

import 'nodes/build-host.pp'

import 'nodes/hv-compute.pp'
import 'nodes/kvm-compute.pp'
import 'nodes/sandboxes.pp'
import 'nodes/packstack_nodes.pp'
import 'nodes/switches.pp'

import 'nodes/logstash.pp'
import 'nodes/pypi.pp'

