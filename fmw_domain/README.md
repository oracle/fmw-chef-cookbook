# fmw_domain

#### Table of Contents

1. [Overview - What is the fmw_domain cookbook?](#overview)
2. [Cookbook Description - What does the cookbook do?](#cookbook-description)
3. [Setup - The basics of getting started with fmw_domain](#setup)
4. [Usage - The recipes available for configuration](#usage)
    * [Recipes](#recipes)
        * [Recipe: default](#recipe-default)
        * [Recipe: domain](#recipe-domain)
        * [Recipe: nodemanager](#recipe-nodemanager)
        * [Recipe: adminserver](#recipe-adminserver)
        * [Recipe: extension_jrf](#recipe-extension_service_bus)
        * [Recipe: extension_service_bus](#recipe-extension_service_bus)
        * [Recipe: extension_soa_suite](#recipe-extension_soa_suite)
        * [Recipe: extension_bam](#recipe-extension_bam)
        * [Recipe: extension_enterprise_scheduler](#recipe-enterprise_scheduler)
        * [Recipe: extension_webtier](#recipe-extension_webtier)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the cookbook](#development)
    * [Contributing to the fmw_domain cookbook](#contributing)
    * [Running tests - A quick guide](#running-tests)

## Overview

The fmw_domain cookbook allows you to create a WebLogic (FMW) Domain with FMW extensions on a Windows, Linux or Solaris host.

## Cookbook description

This cookbook allows you to create a WebLogic (FMW) Domain (10.3.6, 12.1.1) or 12c (12.1.2, 12.1.3, 12.2.1 ) on any Windows, Linux or Solaris host or VM.

## Setup

Add this cookbook to your chef cookbook folder, add fmw_domain recipes to the run list, provide the matching attributes to your chef attributes json file

## Usage

### Recipes

Cookbook defaults

    default['fmw_domain']['nodemanager_port']               = 5556
    default['fmw_domain']['adminserver_startup_arguments']  = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
    default['fmw_domain']['osb_server_startup_arguments']   = '-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
    default['fmw_domain']['soa_server_startup_arguments']   = '-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
    default['fmw_domain']['bam_server_startup_arguments']   = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
    default['fmw_domain']['ess_server_startup_arguments']   = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'

    if platform_family?('windows')
      default['fmw_domain']['domains_dir']    = 'C:/oracle/middleware/user_projects/domains'
      default['fmw_domain']['apps_dir']       = 'C:/oracle/middleware/user_projects/applications'
    else
      default['fmw_domain']['domains_dir']    = '/opt/oracle/middleware/user_projects/domains'
      default['fmw_domain']['apps_dir']       = '/opt/oracle/middleware/user_projects/applications'
    end

#### Databag item

Add an databag entry under the fmw_domains folder and use that entry in ["fmw_domain"]["databag_key"]

DEV_WLS1.json

    {
        "id":                            "DEV_WLS1",
        "domain_name":                   "base",
        "weblogic_user":                 "weblogic",
        "weblogic_password":             "Welcome01",
        "adminserver_name":              "AdminServer",
        "adminserver_listen_address":    "192.168.2.101",
        "adminserver_listen_port":       "7001"
    }

DEV_WLS2.json

    {
        "id":                            "DEV_WLS2",
        "domain_name":                   "base",
        "weblogic_user":                 "weblogic",
        "weblogic_password":             "Welcome01",
        "adminserver_name":              "AdminServer",
        "adminserver_listen_address":    "10.10.10.81",
        "adminserver_listen_port":       "7001",
        "repository_database_url":       "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
        "repository_prefix":             "DEV1",
        "repository_password":           "Welcome02"
    }



#### Recipe default

This is an empty recipe and does not do anything

#### Recipe domain

This will create a basic WebLogic domain

Requires fmw_wls:install

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_jdk::rng_service]",
                   "recipe[fmw_wls::setup]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_domain::domain]",
                   "recipe[fmw_domain::nodemanager]",
                   "recipe[fmw_domain::adminserver]"
                  ],
      "fmw": {
        "java_home_dir":       "/usr/java/jdk1.7.0_75",
        "middleware_home_dir": "/opt/oracle/middleware_1213",
        "weblogic_home_dir":   "/opt/oracle/middleware_1213/wlserver",
        "version":             "12.1.3"
      },
      "fmw_jdk": {
        "source_file":         "/software/jdk-7u75-linux-x64.tar.gz"
      },
      "fmw_wls": {
        "source_file":         "/software/fmw_12.1.3.0.0_wls.jar"
      },
      "fmw_domain": {
        "databag_key":                "DEV_WLS2",
        "domains_dir":                "/opt/oracle/middleware_1213/user_projects/domains",
        "nodemanager_listen_address": "10.10.10.81"
      }
    }

Windows

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_domain::domain]",
                   "recipe[fmw_domain::nodemanager]",
                   "recipe[fmw_domain::adminserver]"
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
        "source_file":         "c:\\software\\fmw_12.1.3.0.0_wls.jar"
      },
      "fmw_domain": {
        "databag_key":                "DEV_WLS1",
        "domains_dir":                "c:\\oracle\\middleware_1213\\user_projects\\domains",
        "apps_dir":                   "c:\\oracle\\middleware_1213\\user_projects\\applications",
        "nodemanager_listen_address": "192.168.2.101",
      }
    }

or with a cluster, servers and nodemanagers

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_domain::domain]",
                   "recipe[fmw_domain::nodemanager]",
                   "recipe[fmw_domain::adminserver]"
                  ],
      "fmw": {
        "java_home_dir":       "c:\\java\\jdk1.8.0_40",
        "middleware_home_dir": "c:\\oracle\\middleware_1213",
        "weblogic_home_dir":   "c:\\oracle\\middleware_1213\\wlserver",
        "version":             "12.1.3"
      },
      "fmw_jdk": {
        "source_file":         "c:\\software\\jdk-8u40-windows-x64.exe"
      },
      "fmw_wls": {
        "source_file":         "c:\\software\\fmw_12.1.3.0.0_wls.jar"
      },
      "fmw_domain": {
        "databag_key":                "DEV_WLS_PLAIN",
        "domains_dir":                "c:\\oracle\\middleware_1213\\user_projects\\domains",
        "apps_dir":                   "c:\\oracle\\middleware_1213\\user_projects\\applications",
        "nodemanager_listen_address": "192.168.2.101",
        "nodemanagers": [
          {
            "id": "node1",
            "listen_address": "192.168.2.110"
          },
          {
            "id": "node2",
            "listen_address": "192.168.2.111"
          }
        ],
        "servers": [
          {
            "id": "server1",
            "nodemanager": "node1",
            "listen_address": "192.168.2.110",
            "listen_port": 8001,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          },
          {
            "id": "server2",
            "nodemanager": "node2",
            "listen_address": "192.168.2.111",
            "listen_port": 8001,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          },
          {
            "id": "server3",
            "nodemanager": "node1",
            "listen_address": "192.168.2.110",
            "listen_port": 9001,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          }
        ],
        "clusters": [
          {
            "id": "cluster1",
            "members": ["server1",
                        "server2"]
          },
          { "id": "cluster2",
            "members": ["server3"]
          }
        ]
      }
    }

or with Fusion Middleware 12c

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]",
                   "recipe[fmw_inst::service_bus]",
                   "recipe[fmw_opatch::soa_suite]",
                   "recipe[fmw_rcu::soa_suite]",
                   "recipe[fmw_domain::domain]",
                   "recipe[fmw_domain::extension_soa_suite]",
                   "recipe[fmw_domain::extension_bam]",
                   "recipe[fmw_domain::extension_service_bus]",
                   "recipe[fmw_domain::extension_enterprise_scheduler]",
                   "recipe[fmw_domain::nodemanager]",
                   "recipe[fmw_domain::adminserver]"
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
      "fmw_inst": {
        "soa_suite_source_file":   "c:\\software\\fmw_12.1.3.0.0_soa_Disk1_1of1.zip",
        "soa_suite_install_type":  "BPM",
        "service_bus_source_file": "c:\\software\\fmw_12.1.3.0.0_osb_Disk1_1of1.zip"
      },
      "fmw_opatch": {
        "soa_suite_patch_id":      "20423408",
        "soa_suite_source_file":   "c:\\software\\p20423408_121300_Generic.zip"
      },
      "fmw_rcu": {
        "databag_key":            "dbnode1_DEV17",
        "rcu_prefix":             "DEV17",
        "oracle_home_dir":        "c:\\oracle\\middleware_1213\\oracle_common",
        "jdbc_database_url":      "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
        "db_database_url":        "10.10.10.15:1521:soarepos.example.com"
      },
      "fmw_domain": {
        "databag_key":                  "DEV_WLS_ALL2",
        "domains_dir":                  "c:\\oracle\\middleware_1213\\user_projects\\domains",
        "apps_dir":                     "c:\\oracle\\middleware_1213\\user_projects\\applications",
        "nodemanager_listen_address":   "192.168.2.101",
        "soa_suite_install_type":       "BPM"
      }
    }


or with Fusion Middleware 11g

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_bsu::weblogic]",
                   "recipe[fmw_inst::soa_suite]",
                   "recipe[fmw_inst::service_bus]",
                   "recipe[fmw_opatch::soa_suite]",
                   "recipe[fmw_opatch::service_bus]",
                   "recipe[fmw_rcu::soa_suite]",
                   "recipe[fmw_domain::domain]",
                   "recipe[fmw_domain::extension_soa_suite]",
                   "recipe[fmw_domain::extension_bam]",
                   "recipe[fmw_domain::extension_service_bus]",
                   "recipe[fmw_domain::nodemanager]",
                   "recipe[fmw_domain::adminserver]"
                  ],
      "fmw": {
        "java_home_dir":       "c:\\java\\jdk1.7.0_75",
        "middleware_home_dir": "c:\\oracle\\middleware_1036",
        "weblogic_home_dir":   "c:\\oracle\\middleware_1036\\wlserver_10.3",
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
      },
      "fmw_inst": {
        "soa_suite_source_file":   "c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip",
        "soa_suite_source_2_file": "c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip",
        "service_bus_source_file": "c:\\software\\ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip"
      },
      "fmw_opatch": {
        "soa_suite_patch_id":        "20423535",
        "soa_suite_source_file":     "c:\\software\\p20423535_111170_Generic.zip",
        "service_bus_patch_id":      "20423630",
        "service_bus_source_file":   "c:\\software\\p20423630_111170_Generic.zip"
      },
      "fmw_rcu": {
        "databag_key":            "dbnode1_DEV16",
        "rcu_prefix":             "DEV16",
        "source_file":            "c:\\software\\ofm_rcu_win_11.1.1.7.0_32_disk1_1of1.zip",
        "jdbc_database_url":      "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
        "db_database_url":        "10.10.10.15:1521:soarepos.example.com"
      },
      "fmw_domain": {
        "databag_key":                "DEV_WLS_ALL",
        "domains_dir":                "c:\\oracle\\middleware_1036\\user_projects\\domains",
        "apps_dir":                   "c:\\oracle\\middleware_1036\\user_projects\\applications",
        "nodemanager_listen_address": "192.168.2.101",
        "soa_suite_install_type":     "BPM"
      }
    }

or with Fusion Middleware in a cluster configuration

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_inst::soa_suite]",
                   "recipe[fmw_inst::service_bus]",
                   "recipe[fmw_opatch::soa_suite]",
                   "recipe[fmw_rcu::soa_suite]",
                   "recipe[fmw_domain::domain]",
                   "recipe[fmw_domain::extension_soa_suite]",
                   "recipe[fmw_domain::extension_bam]",
                   "recipe[fmw_domain::extension_service_bus]",
                   "recipe[fmw_domain::extension_enterprise_scheduler]",
                   "recipe[fmw_domain::nodemanager]",
                   "recipe[fmw_domain::adminserver]"
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
      "fmw_inst": {
        "soa_suite_source_file":   "c:\\software\\fmw_12.1.3.0.0_soa_Disk1_1of1.zip",
        "soa_suite_install_type":  "BPM",
        "service_bus_source_file": "c:\\software\\fmw_12.1.3.0.0_osb_Disk1_1of1.zip"
      },
      "fmw_opatch": {
        "soa_suite_patch_id":      "20423408",
        "soa_suite_source_file":   "c:\\software\\p20423408_121300_Generic.zip"
      },
      "fmw_rcu": {
        "databag_key":            "dbnode1_DEV17",
        "rcu_prefix":             "DEV17",
        "oracle_home_dir":        "c:\\oracle\\middleware_1213\\oracle_common",
        "jdbc_database_url":      "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
        "db_database_url":        "10.10.10.15:1521:soarepos.example.com"
      },
      "fmw_domain": {
        "databag_key":                  "DEV_WLS_ALL2",
        "domains_dir":                  "c:\\oracle\\middleware_1213\\user_projects\\domains",
        "apps_dir":                     "c:\\oracle\\middleware_1213\\user_projects\\applications",
        "nodemanager_listen_address":   "192.168.2.101",
        "soa_suite_cluster":            "soa_cluster",
        "soa_suite_install_type":       "BPM",
        "bam_cluster":                  "bam_cluster",
        "service_bus_cluster":          "sb_cluster",
        "enterprise_scheduler_cluster": "ess_cluster",
        "nodemanagers": [
          {
            "id": "node1",
            "listen_address": "192.168.2.101"
          },
          {
            "id": "node2",
            "listen_address": "192.168.2.101"
          }
        ],
        "servers": [
          {
            "id": "soa12c_server1",
            "nodemanager": "node1",
            "listen_address": "192.168.2.101",
            "listen_port": 8001,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          },
          {
            "id": "soa12c_server2",
            "nodemanager": "node2",
            "listen_address": "192.168.2.101",
            "listen_port": 8002,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          },
          {
            "id": "sb12c_server1",
            "nodemanager": "node1",
            "listen_address": "192.168.2.101",
            "listen_port": 8011,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          },
          {
            "id": "sb12c_server2",
            "nodemanager": "node2",
            "listen_address": "192.168.2.101",
            "listen_port": 8012,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          },
          {
            "id": "bam12c_server1",
            "nodemanager": "node1",
            "listen_address": "192.168.2.101",
            "listen_port": 9001,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          },
          {
            "id": "bam12c_server2",
            "nodemanager": "node2",
            "listen_address": "192.168.2.101",
            "listen_port": 9002,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          },
          {
            "id": "ess12c_server1",
            "nodemanager": "node1",
            "listen_address": "192.168.2.101",
            "listen_port": 8201,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          },
          {
            "id": "ess12c_server2",
            "nodemanager": "node2",
            "listen_address": "192.168.2.101",
            "listen_port": 8202,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          }
        ],
        "clusters": [
          {
            "id": "soa_cluster",
            "members": ["soa12c_server1",
                        "soa12c_server2"]
          },
          {
            "id": "sb_cluster",
            "members": ["sb12c_server1",
                        "sb12c_server2"]
          },
          {
            "id": "bam_cluster",
            "members": ["bam12c_server1",
                        "bam12c_server2"]
          },
          {
            "id": "ess_cluster",
            "members": ["ess12c_server1",
                        "ess12c_server2"]
          }
        ]
      }
    }


or with Fusion Middleware 11g in a cluster configuration

    {
      "run_list": ["recipe[fmw_jdk::install]",
                   "recipe[fmw_wls::install]",
                   "recipe[fmw_bsu::weblogic]",
                   "recipe[fmw_inst::soa_suite]",
                   "recipe[fmw_inst::service_bus]",
                   "recipe[fmw_opatch::soa_suite]",
                   "recipe[fmw_opatch::service_bus]",
                   "recipe[fmw_rcu::soa_suite]",
                   "recipe[fmw_domain::domain]",
                   "recipe[fmw_domain::extension_soa_suite]",
                   "recipe[fmw_domain::extension_bam]",
                   "recipe[fmw_domain::extension_service_bus]",
                   "recipe[fmw_domain::nodemanager]",
                   "recipe[fmw_domain::adminserver]"
                  ],
      "fmw": {
        "java_home_dir":       "c:\\java\\jdk1.7.0_75",
        "middleware_home_dir": "c:\\oracle\\middleware_1036",
        "weblogic_home_dir":   "c:\\oracle\\middleware_1036\\wlserver_10.3",
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
      },
      "fmw_inst": {
        "soa_suite_source_file":   "c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip",
        "soa_suite_source_2_file": "c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip",
        "service_bus_source_file": "c:\\software\\ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip"
      },
      "fmw_opatch": {
        "soa_suite_patch_id":        "20423535",
        "soa_suite_source_file":     "c:\\software\\p20423535_111170_Generic.zip",
        "service_bus_patch_id":      "20423630",
        "service_bus_source_file":   "c:\\software\\p20423630_111170_Generic.zip"
      },
      "fmw_rcu": {
        "databag_key":            "dbnode1_DEV16",
        "rcu_prefix":             "DEV16",
        "source_file":            "c:\\software\\ofm_rcu_win_11.1.1.7.0_32_disk1_1of1.zip",
        "jdbc_database_url":      "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
        "db_database_url":        "10.10.10.15:1521:soarepos.example.com"
      },
      "fmw_domain": {
        "databag_key":                "DEV_WLS_ALL",
        "domains_dir":                "c:\\oracle\\middleware_1036\\user_projects\\domains",
        "apps_dir":                   "c:\\oracle\\middleware_1036\\user_projects\\applications",
        "nodemanager_listen_address": "192.168.2.101",
        "soa_suite_cluster":          "soa_cluster",
        "soa_suite_install_type":     "BPM",
        "bam_cluster":                "bam_cluster",
        "service_bus_cluster":        "sb_cluster",
        "nodemanagers": [
          {
            "id": "node1",
            "listen_address": "192.168.2.101"
          },
          {
            "id": "node2",
            "listen_address": "192.168.2.101"
          }
        ],
        "servers": [
          {
            "id": "soa11g_server1",
            "nodemanager": "node1",
            "listen_address": "192.168.2.101",
            "listen_port": 8001,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Dtangosol.coherence.wka1=192.168.2.101 -Dtangosol.coherence.wka2=192.168.2.101 -Dtangosol.coherence.localhost=192.168.2.101 -Dtangosol.coherence.localport=8089 -Dtangosol.coherence.wka1.port=8089 -Dtangosol.coherence.wka2.port=8189"
          },
          {
            "id": "soa11g_server2",
            "nodemanager": "node2",
            "listen_address": "192.168.2.101",
            "listen_port": 8002,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Dtangosol.coherence.wka1=192.168.2.101 -Dtangosol.coherence.wka2=192.168.2.101 -Dtangosol.coherence.localhost=192.168.2.101 -Dtangosol.coherence.localport=8189 -Dtangosol.coherence.wka1.port=8089 -Dtangosol.coherence.wka2.port=8189"
          },
          {
            "id": "sb11g_server1",
            "nodemanager": "node1",
            "listen_address": "192.168.2.101",
            "listen_port": 8011,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -DOSB.coherence.localhost=192.168.2.101 -DOSB.coherence.localport=7890 -DOSB.coherence.wka1=192.168.2.101 -DOSB.coherence.wka1.port=7890 -DOSB.coherence.wka2=192.168.2.101 -DOSB.coherence.wka2.port=7891"
          },
          {
            "id": "sb11g_server2",
            "nodemanager": "node2",
            "listen_address": "192.168.2.101",
            "listen_port": 8012,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -DOSB.coherence.localhost=192.168.2.101 -DOSB.coherence.localport=7891 -DOSB.coherence.wka1=192.168.2.101 -DOSB.coherence.wka1.port=7890 -DOSB.coherence.wka2=192.168.2.101 -DOSB.coherence.wka2.port=7891"
          },
          {
            "id": "bam11g_server1",
            "nodemanager": "node1",
            "listen_address": "192.168.2.101",
            "listen_port": 9001,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          },
          {
            "id": "bam11g_server2",
            "nodemanager": "node2",
            "listen_address": "192.168.2.101",
            "listen_port": 9002,
            "arguments": "-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m"
          }
        ],
        "clusters": [
          {
            "id": "soa_cluster",
            "members": ["soa11g_server1",
                        "soa11g_server2"]
          },
          {
            "id": "sb_cluster",
            "members": ["sb11g_server1",
                        "sb11g_server2"]
          },
          {
            "id": "bam_cluster",
            "members": ["bam11g_server1",
                        "bam11g_server2"]
          }
        ]
      }
    }

#### Recipe nodemanager

Configures the nodemanager, create and starts the nodemanager service

#### Recipe adminserver

Starts or stops the AdminServer WebLogic instance by connecting to the nodemanager

#### Recipe extension_jrf

Extend the standard domain with JRF (ADF) and the Enterprise Manager (EM), requires in 12c fmw_wls::install with the infra option plus a common database repository created by RCU (fmw_rcu cookbook, for 12.2.1 you can set fmw_domain::restricted = true, this requires not a database repository) or for 11g fmw_wls::install together with a FMW product install like OSB, SOA Suite etc.

With WebLogic infrastructure 12.2.1 you have the option to use the restricted JRF templates. This requires not a database repository for OPSS. To enable this you can set  fmw_domain::restricted = true.

#### Recipe extension_service_bus

Extend the standard domain with Oracle Service Bus, requires fmw_wls::install and fmw_inst::service_bus. This also requires a soa suite database repository created by RCU (fmw_rcu cookbook).

#### Recipe extension_soa_suite

Extend the standard domain with Oracle SOA Suite. Optional add the BPM template to the domain by setting soa_suite_install_type attribute value to 'BPM'. Requires fmw_wls::install and fmw_inst::soa_suite. This also requires a soa suite database repository created by RCU (fmw_rcu cookbook).

#### Recipe extension_bam

Extend the standard domain with BAM of Oracle SOA Suite. Requires fmw_wls::install and fmw_inst::soa_suite. This also requires a soa suite database repository created by RCU (fmw_rcu cookbook).

#### Recipe extension_enterpise_scheduler

Extend the standard domain with Enterprise Schuduler (ESS) of Oracle SOA Suite 12c, is only available for WebLogic 12.1.3 and higher. Requires fmw_wls::install and fmw_inst::soa_suite. This also requires a soa suite database repository created by RCU (fmw_rcu cookbook).

#### Recipe extension_webtier

Only for 12c, Extend the standard domain with Webtier. This also requires a common database repository created by RCU (fmw_rcu cookbook, for 12.2.1 you can set fmw_domain::restricted = true, this requires not a database repository).

With WebLogic infrastructure 12.2.1 you have the option to use the restricted JRF/Webtier templates. This requires not a database repository for OPSS. To enable this you can set  fmw_domain::restricted = true.

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
