node 'pypi' {
  $mirror_dir = "/opt/pypi-mirror";
  $pypi_root = "/var/pypi";

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

  package{"mysql-devel":
     ensure => latest,
  }

  package{"gcc":
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
     require     => [File["${mirror_dir}/mirror.yaml"],Package['mysql-devel'],],
     subscribe   => Exec["install-mirror"],
     timeout     => 3600,
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

  notify {"${hostname} -- WORK IN PROGRESS!":}
}
