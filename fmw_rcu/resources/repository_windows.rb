# Copyright 2015 Oracle Corporation
# All Rights Reserved
#
# Cookbook Name:: fmw_rcu
# Resource:: repository
#
provides :fmw_rcu_repository, os: 'windows'

# create or drop a FMW RCU repository on Oracle Database
actions :create, :drop

# Make create the default action
default_action :create

# Java home folder
attribute :java_home_dir, kind_of: String, required: true
# Middleware home folder
attribute :middleware_home_dir, kind_of: String, required: true
# WebLogic version
attribute :version, kind_of: String, required: true
# Oracle home directory
attribute :oracle_home_dir, kind_of: String, required: true
# Oracle JDBC connect url
attribute :jdbc_connect_url, kind_of: String, required: true
# Oracle database connect url
attribute :db_connect_url, kind_of: String, required: true
# Oracle database RCU sys user
attribute :db_connect_user, kind_of: String, required: true
# Oracle database RCU sys password
attribute :db_connect_password, kind_of: String, required: true
# RCU repository schema prefix
attribute :rcu_prefix, kind_of: String, required: true
# RCU repository components
attribute :rcu_components, kind_of: Array, required: true
# RCU component password
attribute :rcu_component_password, kind_of: String, required: true
# tmp folder
attribute :tmp_dir, kind_of: String, required: true

state_attrs :java_home_dir, :oracle_home_dir, :jdbc_connect_url, :db_connect_url, :db_connect_user, :rcu_prefix, :rcu_components, :tmp_dir

attr_accessor :exists
