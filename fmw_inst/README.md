# fmw_inst

#### Table of Contents

1. [Overview - What is the fmw_inst cookbook?](#overview)
2. [Cookbook Description - What does the cookbook do?](#cookbook-description)
3. [Setup - The basics of getting started with fmw_inst](#setup)
4. [Usage - The recipes available for configuration](#usage)
    * [Recipes](#recipes)
        * [Recipe: default](#recipe-default)
        * [Recipe: soa_suite](#recipe-soa_suite)
        * [Recipe: service_bus](#recipe-service_bus)
        * [Recipe: mft](#recipe-mft)
        * [Recipe: jrf](#recipe-jrf)
        * [Recipe: webcenter](#recipe-webcenter)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the cookbook](#development)
    * [Contributing to the fmw_inst cookbook](#contributing)
    * [Running tests - A quick guide](#running-tests)

## Overview

The fmw_inst cookbook allows you to install any 11g or 12c Oracle Fusion Middleware software on a WebLogic 11g or 12c middleware environment.

## Cookbook description

This cookbook allows you to install any FMW (10.3.6) or 12c (12.1, 12.2) products like SOA Suite, Service Bus, IDM.

## Setup

Add this cookbook to your chef cookbook folder, add fmw_inst recipes to the run list, provide the matching attributes to your chef attributes json file

## Usage

### Recipes

#### Recipe default

This is an empty recipe and does not do anything

#### Recipe soa_suite

This will install the soa suite on a middleware home and has a dependency with the fmw_wls::install recipe

On linux

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]"
                  ],
      "fmw": {
        "java_home_dir":       "/usr/java/jdk1.7.0_75",
        "middleware_home_dir": "/opt/oracle/middleware_1213",
        "version":             "12.1.3"
      },
      "fmw_jdk": {
        "source_file":      "/software/jdk-7u75-linux-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "/software/fmw_12.1.3.0.0_infrastructure.jar",
        "install_type":        "infra"
      },
      "fmw_inst": {
        "soa_suite_source_file":   "/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip",
        "soa_suite_install_type":  "BPM"
      }
    }

    or

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]",
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
      }
    }

On windows

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]"
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
        "soa_suite_source_file":  "c:\\software\\fmw_12.1.3.0.0_soa_Disk1_1of1.zip",
        "soa_suite_install_type": "BPM"
      }
    }

    or

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]"
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
      }
    }

On Solaris

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]"
                  ],
      "fmw": {
        "java_home_dir":    "/usr/jdk/instances/jdk1.7.0_75",
        "middleware_home_dir": "/opt/oracle/middleware_1213",
        "version":             "12.1.3",
      },
      "fmw_jdk": {
        "source_file":      "/software/jdk-7u75-solaris-i586.tar.gz",
        "source_x64_file":  "/software/jdk-7u75-solaris-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "/software/fmw_12.1.3.0.0_infrastructure.jar",
        "install_type":        "infra"
      },
      "fmw_inst": {
        "soa_suite_source_file":  "/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip",
        "soa_suite_install_type": "BPM"
      }
    }

    or

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]"
                  ],
      "fmw": {
        "java_home_dir":    "/usr/jdk/instances/jdk1.7.0_75",
        "middleware_home_dir": "/opt/oracle/middleware_1036",
        "version":             "10.3.6"
      },
      "fmw_jdk": {
        "source_file":      "/software/jdk-7u75-solaris-i586.tar.gz",
        "source_x64_file":  "/software/jdk-7u75-solaris-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "/software/wls1036_generic.jar",
      },
      "fmw_inst": {
        "soa_suite_source_file":   "/software/ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip",
        "soa_suite_source_2_file": "/software/ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip"
      }
    }

#### Recipe service_bus

This will install the service bus on a middleware home and has a dependency with the fmw_wls::install recipe

On linux

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::service_bus]"
                  ],
      "fmw": {
        "java_home_dir":       "/usr/java/jdk1.7.0_75",
        "middleware_home_dir": "/opt/oracle/middleware_1213",
        "version":             "12.1.3"
      },
      "fmw_jdk": {
        "source_file":      "/software/jdk-7u75-linux-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "/software/fmw_12.1.3.0.0_infrastructure.jar",
        "install_type":        "infra"
      },
      "fmw_inst": {
        "service_bus_source_file": "/software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip"
      }
    }


#### Recipe mft

This will install the MFT 12c on a middleware home and has a dependency with the fmw_wls::install recipe

On linux

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::mft]"
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
        "mft_source_file":     "/software/fmw_12.1.3.0.0_mft_Disk1_1of1.zip"
      }
    }

On Windows

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::mft]"
                  ],
      "fmw": {
        "java_home_dir":       "C:\usr\java\jdk1.7.0_75",
        "middleware_home_dir": "C:\opt\oracle\middleware_1213",
        "version":             "12.1.3"
      },
      "fmw_jdk": {
        "source_file":         "C:\software\jdk-7u75-linux-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "c:\\software\\fmw_12.1.3.0.0_infrastructure.jar",
        "install_type":        "infra"
      },
      "fmw_inst": {
        "mft_source_file":     "C:\software\fmw_12.1.3.0.0_mft_Disk1_1of1.zip"
      }
    }



#### Recipe jrf

This will install the 11g JRF/ADFr Suite on a middleware home and has a dependency with the fmw_wls::install recipe

On linux
    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::jrf]"
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
        "jrf_source_file":     "/software/ofm_appdev_generic_11.1.1.9.0_disk1_1of1.zip"
      }
    }


#### Recipe webcenter

This will install the Webcenter Suite on a middleware home and has a dependency with the fmw_wls::install recipe

On linux
    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
	                 "recipe[fmw_inst::webcenter]"
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
	      "webcenter_source_file":   "/software/ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip",
        "webcenter_source_2_file": "/software/ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip"
      }
    }

#### Recipe OIM

This will install Oracle Identity Management on a middleware home and has a dependency on the fmw_wls::install recipe.

On linux
    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::oim]"
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
        "oim_source_file_1":       "/software/ofm_iam_generic_11.1.2.3.0_disk1_1of3.zip",
        "oim_source_file_2":       "/software/ofm_iam_generic_11.1.2.3.0_disk1_2of3.zip",
        "oim_source_file_3":       "/software/ofm_iam_generic_11.1.2.3.0_disk1_3of3.zip",
        "oim_version":             "11.1.2"
      }
    }

On Windows

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::oim]"
                  ],
      "fmw": {
        "java_home_dir":       "C:\usr\java\jdk1.7.0_75",
        "middleware_home_dir": "C:\opt\oracle\middleware_11g",
        "version":             "10.3.6"
      },
      "fmw_jdk": {
        "source_file":         "C:\software\jdk-7u75-linux-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "C:\software\wls1036_generic.jar"
      },
      "fmw_inst": {
        "oim_source_file_1":       "C:\software\ofm_iam_generic_11.1.2.3.0_disk1_1of3.zip",
        "oim_source_file_2":       "C:\software\ofm_iam_generic_11.1.2.3.0_disk1_2of3.zip",
        "oim_source_file_3":       "C:\software\ofm_iam_generic_11.1.2.3.0_disk1_3of3.zip",
        "oim_version":             "11.1.2"
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
