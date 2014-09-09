node 'pypi' {
  $mirror_dir = "/opt/pypi-mirror"
  $pypi_root = "/var/pypi"

  class {'basenode':}
  class {'sensu':}
  class {'sensu_client_plugins': require => Class['sensu'],}

  firewall {'100 allow http':
     state  => ['NEW'],
     port   => '80',
     proto  => 'tcp',
     action => 'accept',
  }

  class {'pypi': 
    pypi_root => "${pypi_root}",
  }

  file{"${mirror_dir}":
    ensure => directory,
  }

  vcsrepo{"${mirror_dir}":
    ensure   => present,
    provider => git,
    source   => 'git://github.com/openstack-infra/pypi-mirror.git',
  }

  alert('Note: It may take a considerable amount of time to populate the mirror.')

  # Note: These are redhat/centos packages!  Needs further work
  # to be working on other distros

  package{"mysql-devel":
     ensure => latest,
  }

  package{"python-devel":
     ensure => latest,
  }

  package{"postgresql-devel":
     ensure => latest,
  }

  package{"pcre-devel":
     ensure => latest,
  }

  package{"libxml2-devel":
     ensure => latest,
  }

  package{"libxslt-devel":
     ensure => latest,
  }

  package{"sqlite-devel":
     ensure => latest,
  }

  package{"openldap-devel":
     ensure => latest,
  }

  package{"zeromq-devel":
     ensure => latest,
  }

  package{"gcc-c++":
     ensure => latest,
  }

  package{"redhat-lsb-core":
     ensure => latest,
  }

  package{"argparse":
     provider => pip,
     ensure   => latest,
  }

  exec{"install-mirror":
    command     => "python setup.py install",
    cwd         => "${mirror_dir}",
    path        => "/bin:/usr/bin",
    subscribe   => Vcsrepo["${mirror_dir}"],
  }

  exec{"populate":
     command     => "run-mirror -c mirror.yaml",
     cwd         => "${mirror_dir}",
     path        => "/usr/bin:/bin",
     require     => [File["${mirror_dir}/mirror.yaml"],Package["mysql-devel"],Package["python-devel"],Package["postgresql-devel"],Package["pcre-devel"],Package["libxml2-devel"],Package["libxslt-devel"],Package["sqlite-devel"],Package["openldap-devel"],Package["zeromq-devel"],Package["gcc-c++"],Package["redhat-lsb-core"],Package["argparse"],],
     subscribe   => Exec["install-mirror"],
     timeout     => 7200,
  }

  file{"${mirror_dir}/mirror.yaml":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    require => File["${mirror_dir}"],
    content => "cache-root: /tmp/cache
mirrors:
  - name: openstack
    projects:
      - https://git.openstack.org/openstack/requirements
    output: ${pypi_root}/packages/openstack
  - name: openstack-infra
    projects:
      - https://git.openstack.org/openstack-infra/config
    output: ${pypi_root}/packages/openstack-infra" 
  }
}
