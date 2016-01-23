# fmw_jdk

#### Table of Contents

1. [Overview - What is the fmw_jdk cookbook?](#overview)
2. [Cookbook Description - What does the cookbook do?](#cookbook-description)
3. [Setup - The basics of getting started with fmw_jdk](#setup)
4. [Usage - The recipes available for configuration](#usage)
    * [Recipes](#recipes)
        * [Recipe: default](#recipe-default)
        * [Recipe: install](#recipe-install)
        * [Recipe: rng_service](#recipe-rng_service)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the cookbook](#development)
    * [Contributing to the fmw_jdk cookbook](#contributing)
    * [Running tests - A quick guide](#running-tests)

## Overview

The fmw_jdk cookbook allows you to install and configure an Oracle JDK on a Windows, Linux or Solaris host. Also it can configure the rng service ( random number generator, urandom) on a linux node, this will fix the lack of Entropy on a linux VM.

## Cookbook description

This cookbook allows you to install any JDK version 7 or 8 on any Windows, Linux or Solaris host or VM. Besides installing the JDK you will also be able to control which JDK will the default by setting all symbolic links for java, javac, keytool etc. For Linux hosts you are also be able to configure and start the rng service ( random number generator, urandom, Hardware RNG Entropy Gatherer Daemon) which solves the lack of Entropy (urandom)

## Setup

Add this cookbook to your chef cookbook folder, add fmw_jdk recipes to the run list, provide the matching attributes to your chef attributes json file

## Usage

### Recipes

#### Recipe default

This is an empty recipe and does not do anything

#### Recipe install

This will install the JDK on a host

rpm can only be used on a RedHat family platform

    {
      "run_list": ["recipe[fmw_jdk::install]" ],
      "fmw": {
        "java_home_dir":    "/usr/java/jdk1.8.0_40"
      },
      "fmw_jdk": {
        "source_file":      "/software/jdk-8u40-linux-x64.rpm"
      }
    }

All other linux distributions ( RedHat family included) can also use tar.gz source_file

    {
      "run_list": ["recipe[fmw_jdk::install]" ],
      "fmw": {
        "java_home_dir":    "/usr/java/jdk1.8.0_40"
      },
      "fmw_jdk": {
        "source_file":      "/software/jdk-8u40-linux-x64.tar.gz"
      }
    }

Windows

    {
      "run_list": ["recipe[fmw_jdk::install]" ],
      "fmw": {
        "java_home_dir":    "c:/java/jdk1.8.0_40"
      },
      "fmw_jdk": {
        "source_file":      "c:/software/jdk-8u40-windows-x64.exe"
      }
    }

    or

    {
      "run_list": ["recipe[fmw_jdk::install]" ],
      "fmw": {
        "java_home_dir":    "c:\\java\\jdk1.8.0_40"
      },
      "fmw_jdk": {
        "source_file":      "c:\\software\\jdk-8u40-windows-x64.exe"
      }
    }

Solaris ( tar.gz or tar.Z SVR4 package)

    {
      "run_list": ["recipe[fmw_jdk::install]" ],
      "fmw": {
        "java_home_dir":    "/usr/jdk/instances/jdk1.8.0_40"
      },
      "fmw_jdk": {
        "source_file":      "/software/jdk-8u40-solaris-x64.tar.gz"
      }
    }

    {
      "run_list": ["recipe[fmw_jdk::install]"],
      "fmw": {
        "java_home_dir":    "/usr/jdk/jdk1.8.0_40"
      },
      "fmw_jdk": {
        "source_file":      "/software/jdk-8u40-solaris-x64.tar.Z"
      }
    }


Solaris JDK 7 with x64 entensions

    {
      "run_list": ["recipe[fmw_jdk::install]"],
      "fmw": {
        "java_home_dir":    "/usr/jdk/instances/jdk1.7.0_75"
      },
      "fmw_jdk": {
        "source_file":      "/software/jdk-7u75-solaris-i586.tar.gz"
        "source_x64_file":  "/software/jdk-7u75-solaris-x64.tar.gz"
      }
    }

    {
      "run_list": ["recipe[fmw_jdk::install]"],
      "fmw": {
        "java_home_dir":    "/usr/jdk/jdk1.7.0_75"
      },
      "fmw_jdk": {
        "source_file":      "/software/jdk-7u75-solaris-i586.tar.Z"
        "source_x64_file":  "/software/jdk-7u75-solaris-x64.tar.Z"
      }
    }


#### Recipe rng_service

This will install and configure the rng package on any RedHat or Debian family linux distribution. For windows or solaris platforms this is not necessary and this recipe will do just a return when this recipe is executed on one of those hosts.

    {
      "run_list": ["recipe[fmw_jdk::rng_service]" ]
    }

    or in combination with the install recipe

    {
      "run_list": ["recipe[fmw_jdk::install]","recipe[fmw_jdk::rng_service]"],
      "fmw_jdk": {
        "java_home_dir":    "/usr/java/jdk1.8.0_40"
      },
      "fmw_jdk": {
        "source_file":      "/software/jdk-8u40-linux-x64.tar.gz"
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
