
node /zuul.*/ {
# class {'zuul':}
  class {'basenode':}
  class {'sensu':}
  class{'sensu_client_plugins': require => Class['sensu'],}
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
