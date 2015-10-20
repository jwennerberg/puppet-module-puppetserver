# puppetserver

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with puppetserver](#setup)
    * [What puppetserver affects](#what-puppetserver-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppetserver](#beginning-with-puppetserver)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Puppet module to manage Puppet Server

## Setup

### Dependencies


## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

### Hiera Usage

Example config:

    puppetserver::service_ensure: stopped
    puppetserver::service_enable: false

    puppetserver::java_args:
      '-Xmx':
        value: '4g'
      '-XX:MaxPermSize=':
        value: '512m'

    puppetserver::puppetserver_settings:
      'jruby-puppet.max-active-instances':
        value: 2
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

    puppetserver::bootstrap_settings:
      'ca.certificate-authority-service':
        line: 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service'
        match: 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service'
      'ca.certificate-authority-disabled-service':
        line: '#puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service'
        match: 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service'

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You may also add any additional sections you feel are
necessary or important to include here. Please use the `## ` header.
