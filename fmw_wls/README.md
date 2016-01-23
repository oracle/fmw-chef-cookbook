# fmw_wls

#### Table of Contents

1. [Overview - What is the fmw_wls cookbook?](#overview)
2. [Cookbook Description - What does the cookbook do?](#cookbook-description)
3. [Setup - The basics of getting started with fmw_wls](#setup)
4. [Usage - The recipes available for configuration](#usage)
    * [Recipes](#recipes)
        * [Recipe: default](#recipe-default)
        * [Recipe: setup](#recipe-setup)
        * [Recipe: install](#recipe-install)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the cookbook](#development)
    * [Contributing to the fmw_wls cookbook](#contributing)
    * [Running tests - A quick guide](#running-tests)

## Overview

The fmw_wls cookbook allows you to install Oracle WebLogic on a Windows, Linux or Solaris host.

## Cookbook description

This cookbook allows you to install any WebLogic 11g (10.3.6, 12.1.1) or 12c (12.1.2, 12.1.3, 12.2.1 ) version on any Windows, Linux or Solaris host or VM.

## Setup

Add this cookbook to your chef cookbook folder, add fmw_wls recipes to the run list, provide the matching attributes to your chef attributes json file

## Usage

### Recipes

Cookbook defaults

    default['fmw']['version']                 = '12.1.3' # 10.3.6|12.1.1|12.1.2|12.1.3|12.2.1
    default['fmw_wls']['install_type']        = 'wls' # infra or wls

    if platform_family?('windows')
      default['fmw']['middleware_home_dir']   = 'C:/oracle/middleware'
      default['fmw']['ora_inventory_dir']     = 'C:\\Program Files\\Oracle\\Inventory'
      default['fmw']['tmp_dir']               = 'C:/temp'
    else
      default['fmw']['middleware_home_dir']   = '/opt/oracle/middleware'
      default['fmw']['os_user']               = 'oracle'
      default['fmw']['os_group']              = 'oinstall'
      default['fmw']['os_shell']              = '/bin/bash'
    end

    case platform_family
    when 'debian', 'rhel'
      default['fmw']['orainst_dir']       = '/etc'
      default['fmw']['user_home_dir']     = '/home'
      default['fmw']['ora_inventory_dir'] = '/home/oracle/oraInventory'
      default['fmw']['tmp_dir']           = '/tmp'
    when 'solaris2'
      default['fmw']['orainst_dir']       = '/var/opt/oracle'
      default['fmw']['user_home_dir']     = '/export/home'
      default['fmw']['ora_inventory_dir'] = '/export/home/oracle/oraInventory'
      default['fmw']['tmp_dir']           = '/var/tmp'
    end


#### Recipe default

This is an empty recipe and does not do anything

#### Recipe setup

This optional step to make sure your host it's ready for installing WebLogic, like creating the webLogic operating user and group on a linux or solaris host.

#### Recipe install

This will install the webLogic on a host and has a dependency with the fmw_jdk::install recipe


Linux distributions

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]"
                  ],
      "fmw": {
        "java_home_dir":       "/usr/java/jdk1.8.0_40",
        "middleware_home_dir": "/opt/oracle/middleware_1213"
      },
      "fmw_jdk": {
        "source_file":         "/software/jdk-8u40-linux-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "/software/fmw_12.1.3.0.0_wls.jar"
      }
    }

    or

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]"
                  ],
      "fmw_jdk": {
        "java_home_dir":       "/usr/java/jdk1.7.0_75",
        "middleware_home_dir": "/opt/oracle/middleware_1213",
        "version":             "12.1.3"
      },
      "fmw_jdk": {
        "source_file":         "/software/jdk-7u75-linux-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "/software/fmw_12.1.3.0.0_infrastructure.jar",
        "install_type":        "infra"
      }
    }

Solaris

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]"
                  ],
      "fmw": {
        "java_home_dir":       "/usr/jdk/instances/jdk1.8.0_40",
        "middleware_home_dir": "/opt/oracle/middleware_1213",
        "version":             "12.1.3"
      },
      "fmw_jdk": {
        "source_file":         "/software/jdk-8u40-solaris-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "/software/fmw_12.1.3.0.0_wls.jar"
      }
    }

    or

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]"
                  ],
      "fmw": {
        "java_home_dir":       "/usr/jdk/instances/jdk1.7.0_75",
        "middleware_home_dir": "/opt/oracle/middleware_1036",
        "version":             "10.3.6"
      },
      "fmw_jdk": {
        "source_file":         "/software/jdk-7u75-solaris-i586.tar.gz",
        "source_x64_file":     "/software/jdk-7u75-solaris-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "/software/wls1036_generic.jar"
      }
    }


Windows

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]"
                  ],
      "fmw": {
        "java_home_dir":       "c:\\java\\jdk1.7.0_75",
        "middleware_home_dir": "c:\\oracle\\middleware_1036",
        "version":             "10.3.6"
      },
      "fmw_jdk": {
        "source_file":         "c:\\software\\jdk-7u75-windows-x64.exe"
      },
      "fmw_wls": {
        "source_file":         "c:\\software\\wls1036_generic.jar"
      }
    }

## Limitations

This should work on Windows, Solaris, Linux (Any RedHat or Debian platform family distribution)

## Development

### Contributing

Community contributions are essential for keeping them great. We want to keep it as easy as possible to contribute changes so that our cookbooks work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

### Running-tests

This project contains tests for foodcritic, ChefSpec, rubocop and Test Kitching. For in-depth information please see their respective documentation.

Quickstart:

    yum install -y libxml2-devel libxslt-devel
    gem install bundler --no-rdoc --no-ri
    bundle install --without development

    bundle exec foodcritic .
    bundle exec rspec
    bundle exec rubocop
    bundle exec rake yard
