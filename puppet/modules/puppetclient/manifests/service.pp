class puppetclient::service {
  service { 'puppet':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}