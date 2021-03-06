
#node 'zuul0.openstack.tld' {
# class {'zuul':}
#  class {'basenode':}
#  class {'sensu':}
#  class{'sensu_client_plugins': require => Class['sensu'],}
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

#notify {"${hostname} we're manually managing for now":}
#}

#node /zuul[0-9]+/ {
node
  'zuul-cinder.openstack.tld',
  '5254005b6b5a' {

# class {'zuul':}
#  class { 'openstack_project::zuul_prod':
#    gerrit_server        => 'review.openstack.org',
#    gerrit_user          => 'hyper-v-ci',
#    zuul_ssh_private_key => '/home/zuul/.ssh/id_rsa',
#    url_pattern          => 'http://logs.openstack.org/{build.parameters[LOG_PATH]}',
#    zuul_url             => 'http://zuul.openstack.tld/p',
#    sysadmins            => hiera('sysadmins'),
#    statsd_host          => 'graphite.openstack.org',
#    gearman_workers      => ['jenkins.openstack.tld'],
#  }
  class {'basenode':}
  # Temporary version lock on Sensu due to a compatibility issue between the puppet module and latest version.
  class {'sensu': version => '0.12.6-1',}
  class {'sensu_client_plugins': require => Class['sensu'],}

  group {'zuul':
    ensure => 'present',
  }

  user {'zuul':
    ensure     => 'present',
    gid        => 'zuul',
    managehome => true,
  }

  ensure_resource('class', 'python', {'pip' => true })

  $zuul_version = hiera('zuul_version','latest')
  package {'zuul':
    ensure   => $zuul_version,
    provider => pip,
    require  => Class['python'],
  }

  service {'zuul':
#    ensure  => stopped,
    require => Package['zuul'],
  }

  file {'/root/.ssh/known_hosts':
    ensure => file,
    owner  => root,
    group  => root,
  }

  file_line {'Github_Host_Keys-1':
    path    => '/root/.ssh/known_hosts',
    require => File['/root/.ssh/known_hosts'],
    line    => '|1|aLQHzwtyviPoHSsRR7lpEZxIAZE=|YFgjt9m7qOSLOAKYxMnv/jwCXIg= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=='
  }
  file_line {'Github_Host_Keys-2':
    path    => '/root/.ssh/known_hosts',
    require => File['/root/.ssh/known_hosts'],
    line    => '|1|89x4leB7e3hy79cw+yyHVH6XE/A=|+niJStZ4OaOJ55knnXhclnSGGLc= ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=='
  }

  vcsrepo {'service-config':
    ensure   => 'latest',
    revision => 'master',
    path     => '/usr/local/src/service-config',
    source   => 'git@github.com:openstack-hyper-v/service-config.git',
    provider => 'git',
    user     => 'root',
    force    => true,
    notify   => Service['zuul'],
    before   => Service['zuul'],
    require  => File_line['Github_Host_Keys-1', 'Github_Host_Keys-2'],
  }

  file { '/etc/init.d/zuul':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => '/usr/local/src/service-config/zuul-service/zuul',
    require => Vcsrepo['service-config'],
    before  => Service['zuul'],
  }

  file {'/etc/zuul':
    ensure  => link,
    force   => true,
    target  => "/usr/local/src/service-config/${hostname}",
    require => [Vcsrepo['service-config'],Package['zuul']],
    notify  => Service['zuul'],
  }

  file { '/home/zuul/.ssh/id_rsa':
    ensure  => file,
    owner   => 'zuul',
    group   => 'zuul',
    mode    => '0700',
    source  => '/usr/local/src/service-config/zuul-keys/id_rsa',
    require => [Vcsrepo['service-config'],User['zuul']]
  }

  file { '/home/zuul/.ssh/hyper-v-ci.pub':
    ensure  => file,
    owner   => 'zuul',
    group   => 'zuul',
    mode    => '0700',
    source  => '/usr/local/src/service-config/zuul-keys/hyper-v-ci.pub',
    require => [Vcsrepo['service-config'],User['zuul']]
  }

  file { '/etc/cron.daily/rotate_zuul':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => '#!/bin/bash
LOGDIR="/var/log/zuul"
if [ -d "$LOGDIR" ]
then
        find "$LOGDIR" -type f -regex ".*\.log\..*-[0-9]+$" -exec gzip {} \;
fi
',
#    source  => "puppet:///modules/openstack_project/zuul/rotate_zuul",
  }

notify {"${hostname} -- WORK IN PROGRESS!":}
}
