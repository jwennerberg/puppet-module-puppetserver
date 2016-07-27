# == Class: puppetserver
#
# Module to manage puppetserver
#
class puppetserver (
  $enable_ca                         = true,
  $package_ensure                    = 'installed',
  $package_name                      = 'puppetserver',
  $service_enable                    = true,
  $service_ensure                    = 'running',
  $service_name                      = 'puppetserver',
  $java_args                         = undef,
  $bootstrap_settings                = undef,
  $bootstrap_settings_hiera_merge    = false,
  $puppetserver_settings             = undef,
  $puppetserver_settings_hiera_merge = false,
  $webserver_settings                = undef,
  $webserver_settings_hiera_merge    = false,
) {

  validate_re($package_ensure, '^installed$|^present$|^absent$')
  validate_re($service_ensure, '^running$|^stopped$')
  validate_string($service_name)

  if is_string($service_enable) {
    $_service_enable = str2bool($service_enable)
  } else {
    $_service_enable = $service_enable
  }
  validate_bool($_service_enable)

  if ! is_array($package_name) {
    validate_string($package_name)
  }

  package { $package_name:
    ensure => $package_ensure,
  }

  include ::puppetserver::config

  if ! defined(Service[$service_name]) {
    service { $service_name:
      ensure  => $service_ensure,
      enable  => $_service_enable,
      require => Package[$package_name],
    }
  }

  Package[$package_name] -> Class[puppetserver::config] ~> Service[$service_name]
}
