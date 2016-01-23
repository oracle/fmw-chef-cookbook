# fmw_opatch

#### Table of Contents

1. [Overview - What is the fmw_opatch cookbook?](#overview)
2. [Cookbook Description - What does the cookbook do?](#cookbook-description)
3. [Setup - The basics of getting started with fmw_opatch](#setup)
4. [Usage - The recipes available for configuration](#usage)
    * [Recipes](#recipes)
        * [Recipe: default](#recipe-default)
        * [Recipe: weblogic](#recipe-weblogic)
        * [Recipe: soa_suite](#recipe-soa_suite)
        * [Recipe: service_bus](#recipe-service_bus)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the cookbook](#development)
    * [Contributing to the fmw_opatch cookbook](#contributing)
    * [Running tests - A quick guide](#running-tests)

## Overview

The fmw_opatch cookbook allows you to Patch Oracle WebLogic 12c or any FMW 11g or 12c product.

## Cookbook description

This cookbook allows you to patch WebLogic 12c middleware environment or any FMW 11g or 12c product like SOA Suite, Service Bus etc.

## Setup

Add this cookbook to your chef cookbook folder, add fmw_opatch recipes to the run list, provide the matching attributes to your chef attributes json file

## Usage

### Recipes

Cookbook defaults


#### Recipe default

This is an empty recipe and does not do anything

#### Recipe weblogic

This will apply the weblogic patch on a Middleware home and has a dependency with the fmw_wls::install recipe

On linux

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_opatch::weblogic]"
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
      "fmw_opatch": {
        "weblogic_patch_id":       "20838345",
        "weblogic_source_file":    "/software/p20838345_121300_Generic.zip"
      }
    }


On windows

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_opatch::weblogic]"
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
      "fmw_opatch": {
        "weblogic_patch_id":       "20838345",
        "weblogic_source_file":    "c:\\software\\p20838345_121300_Generic.zip"
      }
    }


#### Recipe soa_suite

This will apply the soa suite patch on an Oracle home and has a dependency with the fmw_inst::soa_suite recipe

On linux

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]",
                   "recipe[fmw_opatch::soa_suite]",
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
        "soa_suite_source_file":   "/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip"
      },
      "fmw_opatch": {
        "soa_suite_patch_id":      "20423408",
        "soa_suite_source_file":   "/software/p20423408_121300_Generic.zip"
      }
    }


    or

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]",
                   "recipe[fmw_opatch::soa_suite]"
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
      },
      "fmw_opatch": {
        "soa_suite_patch_id":        "20423535",
        "soa_suite_source_file":     "/software/p20423535_111170_Generic.zip"
      }
    }


On windows

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]"
                   "recipe[fmw_opatch::soa_suite]"
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
        "soa_suite_source_file":   "c:\\software\\fmw_12.1.3.0.0_soa_Disk1_1of1.zip"
      },
      "fmw_opatch": {
        "soa_suite_patch_id":      "20423408",
        "soa_suite_source_file":   "c:\\software\\p20423408_121300_Generic.zip"
      }
    }

    or

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]",
                   "recipe[fmw_opatch::soa_suite]"
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
        "soa_suite_source_2_file": "c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip"
      },
      "fmw_opatch": {
        "soa_suite_patch_id":        "20423535",
        "soa_suite_source_file":     "c:\\software\\p20423535_111170_Generic.zip"
      }
    }


#### Recipe service_bus

This will apply the service bus patch on an Oracle home and has a dependency with the fmw_inst::service_bus recipe

On linux

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::service_bus]",
                   "recipe[fmw_opatch::service_bus]"
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
        "service_bus_source_file": "/software/ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip"
      },
      "fmw_opatch": {
        "service_bus_patch_id":      "20423630",
        "service_bus_source_file":   "/software/p20423630_111170_Generic.zip"
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
