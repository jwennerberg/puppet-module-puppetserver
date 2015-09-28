# == Class: puppetserver
#
# Module to manage puppetserver
#
class puppetserver (
  $package_ensure        = 'installed',
  $package_name          = 'puppetserver',
  $service_enable        = true,
  $service_ensure        = 'running',
  $service_name          = 'puppetserver',
  $java_args             = {},
  $bootstrap_settings    = {},
  $puppetserver_settings = {},
  $webserver_settings    = {},
) {

  validate_re($package_ensure, '^installed$|^present$|^absent$')
  validate_re($service_ensure, '^running$|^stopped$')

  if is_string($service_enable) {
    $_service_enable = str2bool($service_enable)
  } else {
    $_service_enable = $service_enable
  }
  validate_bool($_service_enable)

  if is_array($package_name) {
    validate_array($package_name)
  } else {
    validate_string($package_name)
  }

  if is_array($service_name) {
    validate_array($service_name)
  } else {
    validate_string($service_name)
  }

  package { $package_name:
    ensure => $package_ensure,
  }

  include puppetserver::config

  if ! defined(Service[$service_name]) {
    service { $service_name:
      ensure  => $service_ensure,
      enable  => $_service_enable,
      require => Package[$package_name],
    }
  }
}
