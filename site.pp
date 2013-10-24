#if ( $virtual == 'physical') and ( $bios_vendor == 'Dell Inc.') {
#if  $bios_vendor == 'Dell Inc.' {
#  class {'dell_openmanage':}
#}

node /^(norman|mother|ns[0-9\.]+)/ {
  class { 'ipam': }
}

node /quartermaster.*/ {
  class {'quartermaster':}
}

node /^(kvm-compute-[0-9]|neutron-controller+)/ {

  notify {"OpenStack Node: ${hostname}":}
  class {'basenode':}
  class {'basenode::dhcp2static':}
#  class {'dell_openmanage':}
#  class {'dell_openmanage::firmware::update':}
#  class {'packstack::yumrepo':}
}
node /^(openstack-controller).*/{
  notify {"OpenStack Node: ${hostname}":}
  class {'basenode':}
  class {'basenode::dhcp2static':}
#  class {'dell_openmanage':}
#  class {'dell_openmanage::firmware::update':}
  class {'packstack':
    openstack_release => 'havana',
    controller_host   => '10.21.7.8',
    network_host      => '10.21.7.10',
    kvm_compute_host  => '10.21.7.31,10.21.7.32,10.21.7.33,10.21.7.34,10.21.7.35'
  }
}

node /^(frankenstein).*/{
#  $graphical_admin = ['blackbox',
#                     'ipmitool',
#
#                     'freeipmi-tools', 
#                     'tightvncserver', 
#                     'freerdp',
#                     'freerdp-x11',
#                     'ubuntu-virt-mgmt']
#  package {$graphical_admin:
#    ensure => latest,
#  }
#apt::ppa { 'ppa:dotcloud/lxc-docker': }
  class {'jenkins::slave':}
  class {'docker':}
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

}
