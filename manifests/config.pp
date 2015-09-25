#
class puppetserver::config(
  $java_args             = $::puppetserver::java_args,
  $bootstrap_settings    = $::puppetserver::bootstrap_settings,
  $puppetserver_settings = $::puppetserver::puppetserver_settings,
  $webserver_settings    = $::puppetserver::webserver_settings,
) {

  if versioncmp($::puppetversion, '4.0.0') >= 0 {
    $configdir = '/etc/puppetlabs/puppetserver/conf.d'
  } else {
    $configdir = '/etc/puppetserver/conf.d'
  }

  if $java_args {
    validate_hash($java_args)
    $java_args_defaults = {
      'notify' => Service[$::puppetserver::service_name],
    }
    create_resources('puppetserver::config::java_arg', $java_args, $java_args_defaults)
  }

  if $puppetserver_settings {
    validate_hash($puppetserver_settings)
    $puppetserver_defaults = {
      'ensure' => 'present',
      'path'   => "${configdir}/puppetserver.conf",
    }
    create_resources(hocon_setting, $puppetserver_settings, $puppetserver_defaults)
  }

  if $webserver_settings {
    validate_hash($webserver_settings)
    $webserver_defaults = {
      'ensure' => 'present',
      'path'   => "${configdir}/webserver.conf",
    }
    create_resources(hocon_setting, $webserver_settings, $webserver_defaults)
  }
}