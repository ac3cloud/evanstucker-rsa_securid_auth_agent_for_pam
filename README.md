# rsa_securid_auth_agent_for_pam

#### Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Trying to puppetize proprietary products is a terrible and thankless task -
particularly ones with interative install scripts... Regardless, I was
disappointed that no Puppet module existed to configure RSA Authentication
Agent for PAM, so I present you with this pitiful module. This is basically
just a puppetization of the instructions found here:

https://community.rsa.com/docs/DOC-39959

## Usage

1. Open up the appropriate ports in your firewalls and/or security groups. I had to open 5500 UDP and 5550 TCP.

1. Download the agent from here:

   https://community.rsa.com/docs/DOC-61994

1. Create an sdconf.rec file on your RSA server.

1. Create a class named "profile::rsa_securid_auth_agent_for_pam" in your
   Puppet repo with content like this:

```
class profile::rsa_securid_auth_agent_for_pam {
  include ::rsa_securid_auth_agent_for_pam::sshd
  class { 'rsa_securid_auth_agent_for_pam':
    pam_agent_path = '/opt/PAM-Agent_xxxxx.tar',
    sdconf => '/var/ace/sdconf.rec',  # Optional will fall back to default
    install_dir => '/opt/pam', # Optional will fall back to default
    excluded_users => 'user1:user2' # Optional users to exclude from SecurID
    require => [ File['sdconf.rec'], File['pam-agent'] ]
  }
  # Optional service declaration for sshd if you don't have one elsewhere.
  #service { 'sshd':
  #  ensure => running,
  #}
  file { 'sdconf.rec':
    path   => '/var/ace/sdconf.rec'
    mode   => '0600',
    source => "puppet:///modules/${module_name}/rsa_securid_auth_agent_for_pam/sdconf.rec",
  }
  file { 'pam-agent':
    path   => '/opt/PAM-Agent_xxxx.tar'
    source => "puppet:///modules/${module_name}/rsa_securid_auth_agent_for_pam/PAM-Agent_xxxx.tar",
  }
}
```

1. Copy sdconf.rec and PAM-Agent_xxxx.tar to
   modules/profile/files/rsa_securid_auth_agent_for_pam/

1. Did you remember to open up your firewall ports?

## Reference

Here, include a complete list of your module's classes, types, providers,
facts, along with the parameters for each. Users refer to this section (thus
the name "Reference") to find specific details; most users don't read it per
se.

###rsa_securid_auth_agent_for_pam

No parameters.

###rsa_securid_auth_agent_for_pam::sshd

No parameters. Note that this class requires that you are defining Service['sshd'] in your local Puppet code.

## Limitations

This module is currently only designed to work on RHEL 7, it has only been tested with Puppet 4, and it only works with PAM-Agent_v7.1.0.1.16.05_06_13_02_04_01.tar.

## Development

Please help! Make this module less terrible. Make it work with other operating systems. Contact RSA and ask them to stop hiding their download behind an account wall so I can change the source to "http://".
