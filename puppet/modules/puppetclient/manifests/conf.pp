class puppetclient::conf ( $puppetmaster = '', $puppetenv = 'production' ) {
  file { "/etc/puppet/auth.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template("puppetclient/auth.conf"),
  }
  
  file { "/etc/puppet/namespaceauth.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template("puppetclient/namespaceauth.conf"),
  }
  
  file { "/etc/puppet/puppet.conf":
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template("puppetclient/puppet.conf"),
  }
  
  file { "/etc/default/puppet":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/puppetclient/default",
    require => File["/var/run/puppet"]
  }

  file { "/etc/init.d/puppet":
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => "puppet:///modules/puppetclient/initd",
    require => File["/etc/default/puppet"]
  }

  file { "/var/run/puppet":
    owner   => 'root',
    group   => 'root',
    mode    => '1777',
    ensure  => directory
  }
  
  File["/etc/puppet/auth.conf"] ~> Service['puppet']
  File["/etc/puppet/namespaceauth.conf"] ~> Service['puppet']
  File["/etc/puppet/puppet.conf" ] ~> Service['puppet']
  File["/etc/init.d/puppet"] ~> Service['puppet']
}