#
define puppetserver::config::java_arg($value) {

  $target = $::osfamily ? {
    'Debian' => '/etc/default/puppetserver',
    'RedHat' => '/etc/sysconfig/puppetserver',
  }

  ini_subsetting { "java_arg-${name}":
    ensure     => present,
    path       => $target,
    section    => '',
    setting    => 'JAVA_ARGS',
    quote_char => '"',
    subsetting => $name,
    value      => $value,
  }
}
