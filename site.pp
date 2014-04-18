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


node /^git.*/{
#  include classes/git_server
  class {'basenode':}
  class {'sensu':}
  class {'sensu_client_plugins': require => Class['sensu'],}
  class {'gitlab_server': }
}

node /^(docker[0-9]).*/{
  class {'docker':}
  docker::pull{'base':}
  docker::pull{'centos':}
}

node /^(index.docker).*/{
  class {'docker::registry':}
}

node /hawk.*/ {
  $ipmi_network = '10.99.99.0/24'
  class {'basenode':}
  class {'jenkins::slave':
    masterurl => 'http://jenkins.openstack.tld:8080',
  }
  class {'sensu':}
  class {'sensu_client_plugins': require => Class['sensu'],}
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
  class {'sensu_client_plugins': require => Class['sensu_server'],}
  package{'mailutils':
    ensure => present,
  }
}

import 'nodes/log_host.pp'
import 'nodes/quartermaster.pp'
import 'nodes/jenkins.pp'
import 'nodes/vpn.pp'
import 'nodes/frankenstein.pp'
import 'nodes/zuul.pp'


import 'nodes/hv-compute.pp'
import 'nodes/kvm-compute.pp'
import 'nodes/sandboxes.pp'
import 'nodes/packstack_nodes.pp'

import 'nodes/switches.pp'

