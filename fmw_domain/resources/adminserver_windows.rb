#
# Cookbook Name:: fmw_domain
# Resource:: adminserver
#
# Copyright 2015 Oracle. All Rights Reserved
#
provides :fmw_domain_adminserver, os: 'windows'

# Adminserver control on a windows host
actions :start, :stop, :restart

# Make create the default action
default_action :start

# full domain dir path
attribute :domain_dir, kind_of: String, required: true
# WebLogic domain name
attribute :domain_name, kind_of: String, required: true
# WebLogic adminserver name
attribute :adminserver_name, kind_of: String, required: true
# weblogic home path
attribute :weblogic_home_dir, kind_of: String, required: true
# java home path
attribute :java_home_dir, kind_of: String, required: true
# weblogic administration user
attribute :weblogic_user, kind_of: String, required: true
# weblogic password
attribute :weblogic_password, kind_of: String, required: true
# nodemanager listen address
attribute :nodemanager_listen_address, kind_of: String, required: true
# nodemanager port
attribute :nodemanager_port, kind_of: Integer, required: true

attr_accessor :started
