# Class: rsa_securid_auth_agent_for_pam
class rsa_securid_auth_agent_for_pam(
  $pam_agent_path, 
  $sdconf = '', 
  $install_dir = '',
  $excluded_users = undef ) {

  file { '/var/ace':
    ensure => directory,
    mode   => '0700',
  }
  file { '/var/ace/sdopts.rec':
    content => "CLIENT_IP=${::facts[networking][ip]}\n",
    mode    => '0600',
    require => File['/var/ace']
  }
  file{'/opt/pam-agent-install':
    ensure => directory
  }
  archive { $pam_agent_path:
    ensure          => present,
    extract         => true,
    extract_command => 'tar xfz %s --strip-components=1',
    extract_path    => '/opt/pam-agent-install',
    cleanup         => true,
    creates         => '/opt/pam-agent-install/install_pam.sh',
    require         => File[$pam_agent_path]
  }
  ensure_packages(['expect'], { ensure => installed })
  file { '/opt/pam.expect':
    mode   => '0755',
    content => template("${module_name}/pam.expect.erb")
  }
  if $::facts[os][architecture] == 'x86_64' {
    $bits = '64'
  }
  else {
    $bits = ''
  }
  exec { '/opt/pam.expect':
    creates => "/usr/lib${bits}/security/pam_securid.so",
    require => [
      Package['expect'],
      Archive[$pam_agent_path:],
    ],
  }
  file { '/etc/sd_pam.conf':
    content => template("${module_name}/sd_pam.conf.erb",
  }
}
