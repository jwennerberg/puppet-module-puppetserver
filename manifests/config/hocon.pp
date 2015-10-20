#
define puppetserver::config::hocon(
  $value,
  $path,
  $setting = $title,
  $ensure  = 'present',
  $type    = undef,
) {

  hocon_setting { "hocon-${name}":
    ensure  => $ensure,
    path    => $path,
    setting => $setting,
    value   => $value,
    type    => $type,
  }
}
