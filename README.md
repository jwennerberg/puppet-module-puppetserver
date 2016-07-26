# puppetserver

## Overview

Puppet module to manage Puppet Server

### Dependencies

* [puppetlabs-stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) (>= 4.0.0)
* [puppetlabs-inifile](https://forge.puppetlabs.com/puppetlabs/inifile) (>= 1.1.0)
* [puppetlabs-hocon](https://forge.puppetlabs.com/puppetlabs/hocon) (>= 0.9.0 < 1.0.0)

## Usage

Manage puppetserver with default settings

    include puppetserver

### Example configuration

    class { puppetserver:
      enable_ca => false,
      java_args => {
        '-Xms' => { 'value' => '2g' },
        '-Xmx' => { 'value' => '4g' }
      },
    }

### Hiera Example

    puppetserver::enable_ca: false

    puppetserver::java_args:
      '-Xmx':
        value: '4g'
      '-XX:MaxPermSize=':
        value: '512m'

    puppetserver::puppetserver_settings:
      'jruby-puppet.max-active-instances':
        value: 6
      'profiler.enabled':
        value: true
      'puppet-admin.client-whitelitst':
        type: 'array'
        value:
          - 'host1.domain.tld'

    puppetserver::webserver_settings:
      'webserver.ssl-port':
        type: 'number'
        value: 9140


## Reference

### Class: puppetserver

Class to install package and manage puppetserver service. Configuration is done by `puppetserver::config`.

#### `enable_ca`
Boolean to control if the CA service should be enabled.

Default: `true`

#### `package_ensure`
Ensure attribute for the package

Default: `'installed'`

#### `package_name`
Name of the package(s) to manage

Default: `'puppetserver'`

#### `service_enable`
Enable attribute for the service

Default: `true`

#### `service_ensure`
Ensure attribute for the service

Default: `'running'`

#### `java_args`
Hash with Java arguments to set for puppetserver. `puppetserver::config::java_arg` resources are created from hash.

Default: `undef`

#### `bootstrap_settings`
Hash with `file_line` resources for configuring lines in bootstrap.cfg

Default: `undef`

#### `bootstrap_settings_hiera_merge`
Boolean to trigger merging hashes for `bootstrap_settings` through all hiera levels.

Default: `false`

#### `puppetserver_settings`
Hash with HOCON style settings for puppetserver.conf. `puppetserver::config::hocon` resources are created from hash.

Default: `undef`

#### `puppetserver_settings_hiera_merge`
Boolean to trigger merging hashes for `puppetserver_settings` through all hiera levels.

Default: `false`

#### `webserver_settings`
Hash with HOCON style settings for webserver.conf. `puppetserver::config::hocon` resources are created from hash.

Default: `undef`

#### `webserver_settings_hiera_merge`
Boolean to trigger merging hashes for `webserver_settings` through all hiera levels.

Default: `false`


### Class: puppetserver::config

Internal class to do puppetserver configuration.

#### `enable_ca`
Boolean to control if the CA service should be enabled.

Default: `$::puppetserver::enable_ca`

#### `java_args`
Hash with Java arguments to set for puppetserver. `puppetserver::config::java_arg` resources are created from hash.

Default: `$::puppetserver::java_args`

#### `bootstrap_settings`
Hash with `file_line` resources for configuring lines in bootstrap.cfg

Default: `$::puppetserver::bootstrap_settings`

#### `puppetserver_settings`
Hash with HOCON style settings for puppetserver.conf. `puppetserver::config::hocon` resources are created from hash.

Default: `$::puppetserver::puppetserver_settings`

#### `webserver_settings`
Hash with HOCON style settings for webserver.conf. `puppetserver::config::hocon` resources are created from hash.

Default: `$::puppetserver::webserver_settings`


### Resource: puppetserver::config::java_arg

Wrapper to manage JAVA_ARGS in puppetserver sysconfig. Uses `ini_subsetting` from `puppetlabs-inifile`.

#### `namevar`
Name of the setting to change.

#### `ensure`
Set to `absent` to remove a setting

Default: `present`

#### `value`
Value for the setting.


### Resource: puppetserver::config::hocon

Wrapper to create `hocon_setting` resources from `puppetlabs-hocon`.

#### `ensure`
Ensures that the resource is present. Valid values are 'present', 'absent'.

Default: `present`

#### `path`
The HOCON file in which Puppet will ensure the specified setting.

#### `setting` (namevar)
The name of the HOCON file setting to be defined.

#### `type`
The type of the value passed into the value parameter. This value should be a string, with valid values being 'number', 'boolean', 'string', 'hash', 'array', 'array_element', and 'text'.


## Limitations

Module is tested using Puppet 3.8.x and Puppetserver 1.x on el7.
