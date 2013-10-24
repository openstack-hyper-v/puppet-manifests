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

node /git.*/ {
  class { 'apt': }
  class { 'redis': }
  class { 'nginx': require => Class['redis'], }
  
  class {
    'ruby':
      version         => $ruby_version,
      rubygems_update => false;
  }

  class { 'ruby::dev': require => Class['ruby'], }

  if $::lsbdistcodename == 'precise' {
    package {
      ['build-essential','libssl-dev','libgdbm-dev','libreadline-dev',
      'libncurses5-dev','libffi-dev','libcurl4-openssl-dev']:
        ensure => installed;
    }

    $ruby_version = '4.9'

    exec {
      'ruby-version':
        command     => '/usr/bin/update-alternatives --set ruby /usr/bin/ruby1.9.1',
        user        => root,
        logoutput   => 'on_failure';
      'gem-version':
        command     => '/usr/bin/update-alternatives --set gem /usr/bin/gem1.9.1',
        user        => root,
        logoutput   => 'on_failure';
    }
  } else {
    $ruby_version = '1:1.9.3'
  }
  
  class { 'mysql::server': }
  class { 'gitlab_mysql_db': require  => Class['mysql::config'], }
  
  class { 'gitlab': require => [Class['nginx'],Class['gitlab_mysql_db']], }
  class { 'gitlab_users': require => Class['gitlab'], }
}

#classes used by 'git' node definition
class gitlab_mysql_db ( $gitlab_db_list = hiera('gitlab::mysql::db_list') ) {
  create_resources('mysql::db', $gitlab_db_list)
}

class gitlab_users ( $gitlab_user_list = hiera('gitlab::user_list') ) {
  $gitlab_user_list.each { |$val| create_resources('gitlab::user', $val) }
}
#end 'git' node classes
