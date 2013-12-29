# Class: bamboo
#
# This module manages Atlassian Bamboo
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Define['wget']
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
class bamboo (
  $version = '4.4.0',
  $extension = 'tar.gz',
  $installdir = '/usr/local',
  $home = '/var/local/bamboo',
  $user = 'bamboo'){

  $srcdir = '/usr/local/src'
  $dir = "${installdir}/bamboo-${version}"

  File {
    owner  => $user,
    group  => $user,
  }

  if !defined(User[$user]) {
    user { $user:
      ensure     => present,
      home       => $home,
      managehome => false,
      system     => true,
    }
  }

  wget::fetch { 'bamboo':
    source      => "http://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${version}.${extension}",
    destination => "${srcdir}/atlassian-bamboo-${version}.tar.gz",
  } ->
  exec { 'bamboo':
    command => "tar zxvf ${srcdir}/atlassian-bamboo-${version}.tar.gz && mv atlassian-bamboo-${version} bamboo-${version} && chown -R ${user}:${user} bamboo-${version}",
    creates => "${installdir}/bamboo-${version}",
    cwd     => $installdir,
    logoutput => "on_failure",
  } ->
  file { $home:
    ensure => directory,
  } ->
  file { "${home}/logs":
    ensure => directory,
  } ->
  file { "${dir}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties":
    content => "bamboo.home=${home}/data",
  }->
  file { '/etc/init.d/bamboo':
    ensure => 'file',
    content => template("bamboo/init.d.erb"),
    mode => 'a+X'
  }~>
  file { '/etc/default/bamboo':
    ensure  => present,
    content => "RUN_AS_USER=${user}
BAMBOO_PID=${home}/bamboo.pid
BAMBOO_LOG_FILE=${home}/logs/bamboo.log",
  }# ~>
  #service { 'bamboo':
  #  ensure     => running,
  #  enable     => false, # service bamboo does not support chkconfig
  #  hasrestart => true,
  #  hasstatus  => false,
  #}
  ##Bamboo currently does not know when it's running so it would keep starting itself

}
