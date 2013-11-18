class git_server {
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
  
  class { 'gitlab_clone_repos': require => Class['gitlab'], }
  class { 'gitlab_import_repos': require => Class['gitlab_clone_repos'], }
  class { 'gitlab_users': require => Class['gitlab_import_repos'], }
  class { 'gitlab_add_users_to_groups': require => [Class['gitlab_import_repos'], Class['gitlab_users']], }
  
  # Cripple the built-in admin account after installation to avoid security issues later...
  class { 'gitlab_cripple_admin': require => Class['gitlab_add_users_to_groups'], }
}

#classes used by 'git' node definition
class gitlab_mysql_db ( $gitlab_db_list = hiera('gitlab::mysql::db_list') ) {
  create_resources('mysql::db', $gitlab_db_list)
}

class gitlab_users ( $gitlab_user_list = hiera('gitlab::user_list') ) {
  $gitlab_user_list.each { |$val| create_resources('gitlab::user', $val) }
}

class gitlab_clone_repos ( 
  $gitlab_repo_url_base = hiera('gitlab::repo_url_base'),
  $gitlab_repo_list = hiera('gitlab::repo_list'),
  $repo_root = "${gitlab::gitlab_repodir}/repositories",
) {
  $gitlab_repo_list.each { |$groupname, $repos|
    $repos.each { |$repo_name, $repo_source|
      if $repo_name =~ /.*\.git$/ {
        $real_name = $repo_name
      } else {
        $real_name = "${repo_name}.git"
      }
      vcsrepo {"${repo_root}/${groupname}/${real_name}":
        ensure => bare,
        provider => git,
        source => "${gitlab_repo_url_base}${repo_source}",
      }
    }
  }
}

class gitlab_add_users_to_groups ( $gitlab_groups_users_list = hiera('gitlab::groups_users_list') ) {
  $gitlab_groups_users_list.each { |$groupname, $users_list|
    $users_list.each { |$user_email|
      gitlab::group_user { "${groupname}_${user_email}":
        user_email => $user_email,
        groupname  => $groupname,
      }
    }
  }
}

class gitlab_import_repos (
  $repo_home = hiera('gitlab::gitlab_repodir'),
) {
  exec {'Import bare repos':
      command     => 'bundle exec rake gitlab:import:repos RAILS_ENV=production',
      provider    => 'shell',
      cwd         => "${repo_home}/gitlab",
      user        => $git_user,
      require     => Package['bundler'],
  }
}

class gitlab_cripple_admin () { gitlab::cripple_user {'admin@local.host': }}
