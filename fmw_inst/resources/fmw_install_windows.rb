# Copyright 2015 Oracle Corporation
# All Rights Reserved
#
# Cookbook Name:: fmw_inst
# Resource:: fmw_install
#
provides :fmw_inst_fmw_install, os: 'windows'

# Installs FMW 11g,12c software on a windows host
actions :install

# Make create the default action
default_action :install

# WebLogic Version
attribute :version, kind_of: String, required: true
# Oracle home folder
attribute :oracle_home_dir, kind_of: String, required: true, name_attribute: true
# Java home folder
attribute :java_home_dir, kind_of: String, required: true
# Windows (extracted) FMW installer file
attribute :installer_file, kind_of: String, required: true
# FMW response file
attribute :rsp_file, kind_of: String, required: true
# tmp folder
attribute :tmp_dir, kind_of: String, required: true

state_attrs :java_home_dir, :middleware_home_dir, :version, :tmp_dir, :rsp_file

attr_accessor :exists
