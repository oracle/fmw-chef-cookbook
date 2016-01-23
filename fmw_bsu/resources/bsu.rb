# Copyright 2015 Oracle Corporation
# All Rights Reserved
#
# Cookbook Name:: fmw_bsu
# Resource:: bsu
#
provides :fmw_bsu_bsu, os: [ 'linux', 'solaris2']

# install or remove BSU patch on a  WebLogic home
actions :install, :remove

# Make create the default action
default_action :install

# BSU patch id
attribute :patch_id, kind_of: String, required: true
# Middleware home folder
attribute :middleware_home_dir, kind_of: String, required: true
# WebLogic Operating system user
attribute :os_user, kind_of: String, required: true

state_attrs :patch_id, :oracle_home_dir, :os_user

attr_accessor :exists
