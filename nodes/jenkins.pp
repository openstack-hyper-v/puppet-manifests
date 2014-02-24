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

