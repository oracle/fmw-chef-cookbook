# fmw_rcu

#### Table of Contents

1. [Overview - What is the fmw_rcu cookbook?](#overview)
2. [Cookbook Description - What does the cookbook do?](#cookbook-description)
3. [Setup - The basics of getting started with fmw_rcu](#setup)
4. [Usage - The recipes available for configuration](#usage)
    * [Recipes](#recipes)
        * [Recipe: default](#recipe-default)
        * [Recipe: soa_suite](#recipe-soa_suite)
        * [Recipe: common](#recipe-common)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the cookbook](#development)
    * [Contributing to the fmw_rcu cookbook](#contributing)
    * [Running tests - A quick guide](#running-tests)

## Overview

The fmw_rcu cookbook allows you to create or drop a FMW repository on a 11g or 12c Oracle Database.

## Cookbook description

This cookbook allows you to create a 11g, 11gR2 or 12c FMW soa suite, webcenter or OIM/OAM repository on any 11.2.0.4 or 12c Oracle Database.

## Setup

Add this cookbook to your chef cookbook folder, add fmw_rcu recipes to the run list, provide the matching attributes to your chef attributes json file

## Usage

### Recipes

#### Cookbook defaults

    default['fmw_rcu']['db_sys_user']     = 'sys'
    default['fmw_rcu']['rcu_prefix']      = 'DEV1'

#### Databag item

Add an databag entry under the fmw_databases folder and use that entry in ["fmw_rcu"]["databag_key"]

dbnode1_DEV1.json

    {
        "id":                     "dbnode1_DEV1",
        "db_sys_password":        "Welcome01",
        "rcu_component_password": "Welcome02"
    }

dbnode1_DEV2.json

    {
        "id":                     "dbnode1_DEV2",
        "db_sys_password":        "Welcome01",
        "rcu_component_password": "Welcome02"
    }


#### Recipe default

This is an empty recipe and does not do anything

#### Recipe soa_suite

This will create or drop a FMW SOA Suite repository

Requires the fmw_inst::soa_suite recipe when webLogic version is 12c else it requires the fmw_wls::install recipe

On Linux

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]",
                   "recipe[fmw_inst::service_bus]",
                   "recipe[fmw_rcu::soa_suite]"
                  ],
      "fmw": {
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
      },
      "fmw_inst": {
        "soa_suite_source_file":   "/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip",
        "soa_suite_install_type":  "BPM",
        "service_bus_source_file": "/software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip"
      },
      "fmw_rcu": {
        "databag_key":            "dbnode1_DEV1",
        "rcu_prefix":             "DEV1",
        "oracle_home_dir":        "/opt/oracle/middleware_1213/oracle_common",
        "db_sys_password":        "Welcome01",
        "jdbc_database_url":      "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
        "db_database_url":        "10.10.10.15:1521:soarepos.example.com",
        "rcu_component_password": "Welcome02"
      }
    }

    or

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]",
                   "recipe[fmw_inst::service_bus]",
                   "recipe[fmw_rcu::soa_suite]"
                  ],
      "fmw": {
        "java_home_dir":       "/usr/java/jdk1.7.0_75",
        "middleware_home_dir": "/opt/oracle/middleware_11g",
        "version":             "10.3.6"
      },
      "fmw_jdk": {
        "source_file":         "/software/jdk-7u75-linux-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "/software/wls1036_generic.jar"
      },
      "fmw_inst": {
        "soa_suite_source_file":   "/software/ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip",
        "soa_suite_source_2_file": "/software/ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip",
        "service_bus_source_file": "/software/ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip"
      },
      "fmw_rcu": {
        "source_file":            "/software/ofm_rcu_linux_11.1.1.7.0_64_disk1_1of1.zip",
        "databag_key":            "dbnode1_DEV4",
        "rcu_prefix":             "DEV4",
        "db_sys_password":        "Welcome01",
        "jdbc_database_url":      "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
        "db_database_url":        "10.10.10.15:1521:soarepos.example.com",
        "rcu_component_password": "Welcome02"
      }
    }


On Windows

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]",
                   "recipe[fmw_inst::service_bus]",
                   "recipe[fmw_rcu::soa_suite]"
                  ],
      "fmw": {
        "java_home_dir":       "c:\\java\\jdk1.7.0_75",
        "middleware_home_dir": "c:\\oracle\\middleware_1213",
        "version":             "12.1.3"
      },
      "fmw_jdk": {
        "source_file":         "c:\\software\\jdk-7u75-windows-x64.exe"
      },
      "fmw_wls": {
        "source_file":         "c:\\software\\fmw_12.1.3.0.0_infrastructure.jar",
        "install_type":        "infra"
      },
      "fmw_inst": {
        "soa_suite_source_file":   "c:\\software\\fmw_12.1.3.0.0_soa_Disk1_1of1.zip",
        "soa_suite_install_type":  "BPM",
        "service_bus_source_file": "c:\\software\\fmw_12.1.3.0.0_osb_Disk1_1of1.zip"
      },
      "fmw_rcu": {
        "databag_key":            "dbnode1_DEV2",
        "rcu_prefix":             "DEV2",
        "oracle_home_dir":        "c:\\oracle\\middleware_1213\\oracle_common",
        "db_sys_password":        "Welcome01",
        "jdbc_database_url":      "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
        "db_database_url":        "10.10.10.15:1521:soarepos",
        "rcu_component_password": "Welcome02"
      }
    }

    or

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]",
                   "recipe[fmw_inst::service_bus]",
                   "recipe[fmw_rcu::soa_suite]"
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
      },
      "fmw_inst": {
        "soa_suite_source_file":   "c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip",
        "soa_suite_source_2_file": "c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip",
        "service_bus_source_file": "c:\\software\\ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip"
      },
      "fmw_rcu": {
        "source_file":            "c:\\software\\ofm_rcu_win_11.1.1.7.0_32_disk1_1of1.zip",
        "databag_key":            "dbnode1_DEV3",
        "rcu_prefix":             "DEV3",
        "db_sys_password":        "Welcome01",
        "jdbc_database_url":      "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
        "db_database_url":        "10.10.10.15:1521:soarepos.example.com",
        "rcu_component_password": "Welcome02"
      }
    }

#### Recipe common

This will create or drop a FMW repository for a basic Fusion middleware domain with OPSS, UMS etc

Requires the fmw_wls::install recipe

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_rcu::common]"
                  ],
      "fmw": {
        "java_home_dir":       "c:\\java\\jdk1.7.0_75",
        "middleware_home_dir": "c:\\oracle\\middleware_1213",
        "weblogic_home_dir":   "c:\\oracle\\middleware_1213\\wlserver",
        "version":             "12.1.3"
      },
      "fmw_jdk": {
        "source_file":         "c:\\software\\jdk-7u75-windows-x64.exe"
      },
      "fmw_wls": {
        "source_file":         "c:\\software\\fmw_12.1.3.0.0_infrastructure.jar",
        "install_type":        "infra"
      },
      "fmw_rcu": {
        "databag_key":            "dbnode1_DEV1",
        "rcu_prefix":             "DEV1",
        "oracle_home_dir":        "c:\\oracle\\middleware_1213\\oracle_common",
        "jdbc_database_url":      "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
        "db_database_url":        "10.10.10.15:1521:soarepos.example.com"
      }
    }


## Limitations

This should work on Windows, Linux (Any RedHat or Debian platform family distribution)

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
