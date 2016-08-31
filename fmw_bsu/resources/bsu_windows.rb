# Copyright 2015 Oracle Corporation
# All Rights Reserved
#
# Cookbook Name:: fmw_bsu
# Resource:: bsu
#
provides :fmw_bsu_bsu, os: 'windows'

# install or remove BSU patch on a  WebLogic home
actions :install, :remove

# Make create the default action
default_action :install

# BSU patch id
attribute :patch_id, kind_of: String, required: true
# Middleware home folder
attribute :middleware_home_dir, kind_of: String, required: true

state_attrs :patch_id, :middleware_home_dir

attr_accessor :exists
