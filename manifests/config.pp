#
class puppetserver::config(
  $enable_ca                         = $::puppetserver::enable_ca,
  $java_args                         = $::puppetserver::java_args,
  $bootstrap_settings                = $::puppetserver::bootstrap_settings,
  $bootstrap_settings_hiera_merge    = $::puppetserver::bootstrap_settings_hiera_merge,
  $puppetserver_settings             = $::puppetserver::puppetserver_settings,
  $puppetserver_settings_hiera_merge = $::puppetserver::puppetserver_settings_hiera_merge,
  $webserver_settings                = $::puppetserver::webserver_settings,
  $webserver_settings_hiera_merge    = $::puppetserver::webserver_settings_hiera_merge,

) inherits puppetserver {

  # variable preparations
  case $bootstrap_settings_hiera_merge {
    true, 'true':   { $bootstrap_settings_real = hiera_hash(puppetserver::bootstrap_settings, {} ) } # lint:ignore:quoted_booleans
    false, 'false': { $bootstrap_settings_real = $bootstrap_settings } # lint:ignore:quoted_booleans
    default:        { fail('puppetserver::bootstrap_settings_hiera_merge is not a boolean.') }
  }

  case $puppetserver_settings_hiera_merge {
    true, 'true':   { $puppetserver_settings_real = hiera_hash(puppetserver::puppetserver_settings, {} ) } # lint:ignore:quoted_booleans
    false, 'false': { $puppetserver_settings_real = $puppetserver_settings } # lint:ignore:quoted_booleans
    default:        { fail('puppetserver::puppetserver_settings_hiera_merge is not a boolean.') }
  }

  case $webserver_settings_hiera_merge {
    true, 'true':   { $webserver_settings_real = hiera_hash(puppetserver::webserver_settings, {} ) } # lint:ignore:quoted_booleans
    false, 'false': { $webserver_settings_real = $webserver_settings } # lint:ignore:quoted_booleans
    default:        { fail('puppetserver::webserver_settings_hiera_merge is not a boolean.') }
  }

  if is_string($enable_ca) {
    $_enable_ca = str2bool($enable_ca)
  } else {
    $_enable_ca = $enable_ca
  }
  validate_bool($_enable_ca)

  if versioncmp($::puppetversion, '4.0.0') >= 0 {
    $configdir = '/etc/puppetlabs/puppetserver/conf.d'
    $bootstrap_cfg = '/etc/puppetlabs/puppetserver/bootstrap.cfg'
  } else {
    $configdir = '/etc/puppetserver/conf.d'
    $bootstrap_cfg = '/etc/puppetserver/bootstrap.cfg'
  }

  if $_enable_ca == true {
    $bootstrap_ca_defaults = {
      'ca.certificate-authority-service' => {
        'line'  => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
        'match' => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
      },
      'ca.certificate-authority-disabled-service' => {
        'line'  => '#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
        'match' => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
      },
    }
  } else {
    $bootstrap_ca_defaults = {
      'ca.certificate-authority-service' => {
        'line'  => '#puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
        'match' => 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service',
      },
      'ca.certificate-authority-disabled-service' => {
        'line'  => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
        'match' => 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service',
      },
    }
  }

  if $java_args {
    validate_hash($java_args)
    $java_args_defaults = {
      'notify' => Service[$::puppetserver::service_name],
    }
    create_resources('puppetserver::config::java_arg', $java_args, $java_args_defaults)
  }

  if $bootstrap_settings_real {
    validate_hash($bootstrap_settings_real)
    $_bootstrap_settings = merge($bootstrap_ca_defaults, $bootstrap_settings_real)
  } else {
    $_bootstrap_settings = $bootstrap_ca_defaults
  }
  $bootstrap_defaults = {
    'path' => $bootstrap_cfg,
  }
  create_resources(file_line, $_bootstrap_settings, $bootstrap_defaults)

  if $puppetserver_settings_real {
    validate_hash($puppetserver_settings_real)
    $puppetserver_defaults = {
      'ensure' => 'present',
      'path'   => "${configdir}/puppetserver.conf",
    }
    create_resources('puppetserver::config::hocon', $puppetserver_settings_real, $puppetserver_defaults)
  }

  if $webserver_settings_real {
    validate_hash($webserver_settings_real)
    $webserver_defaults = {
      'ensure' => 'present',
      'path'   => "${configdir}/webserver.conf",
    }
    create_resources('puppetserver::config::hocon', $webserver_settings_real, $webserver_defaults)
  }
}
