# fmw_bsu

#### Table of Contents

1. [Overview - What is the fmw_bsu cookbook?](#overview)
2. [Cookbook Description - What does the cookbook do?](#cookbook-description)
3. [Setup - The basics of getting started with fmw_bsu](#setup)
4. [Usage - The recipes available for configuration](#usage)
    * [Recipes](#recipes)
        * [Recipe: default](#recipe-default)
        * [Recipe: weblogic](#recipe-weblogic)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the cookbook](#development)
    * [Contributing to the fmw_bsu cookbook](#contributing)
    * [Running tests - A quick guide](#running-tests)

## Overview

The fmw_bsu cookbook allows you to patch Oracle WebLogic 10.3.6 or 12.1.1.

## Cookbook description

This cookbook allows you to patch Oracle WebLogic 10.3.6 or 12.1.1, this won't work on WebLogic 12.1.2  or higher. For WebLogic 12c you can use the fmw_opatch cookbook.

## Setup

Add this cookbook to your chef cookbook folder, add fmw_bsu recipes to the run list, provide the matching attributes to your chef attributes json file

## Usage

### Recipes

Cookbook defaults


#### Recipe default

This is an empty recipe and does not do anything

#### Recipe weblogic

This will install the 10.3.6 or 12.1.1 WebLogic BSU patch and has a dependency with the fmw_wls::install recipe


Linux distributions

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_bsu::weblogic]"
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
      "fmw_bsu": {
        "patch_id":            "YUIS",
        "source_file":         "/software/p20181997_1036_Generic.zip"
      }
    }

Solaris

    {
      "run_list": ["recipe[fmwjdk::install]",
                   "recipe[fmwwls::setup]",
                   "recipe[fmwwls::install]",
                   "recipe[fmw_bsu::weblogic]"
                  ],
      "fmwjdk": {
        "java_home_dir":    "/usr/jdk/instances/jdk1.7.0_75",
        "source_file":      "/software/jdk-7u75-solaris-i586.tar.gz",
        "source_x64_file":  "/software/jdk-7u75-solaris-x64.tar.gz"
      },
      "fmwwls": {
        "java_home_dir":       "/usr/jdk/instances/jdk1.7.0_75",
        "source_file":         "/software/wls1036_generic.jar",
        "middleware_home_dir": "/opt/oracle/middleware_1036",
        "version":             "10.3.6"
      },
      "fmw_bsu": {
        "patch_id":            "YUIS",
        "source_file":         "/software/p20181997_1036_Generic.zip"
      }
    }

Windows

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_bsu::weblogic]"
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
      "fmw_bsu": {
        "patch_id":            "YUIS",
        "source_file":         "c:\\software\\p20181997_1036_Generic.zip"
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
