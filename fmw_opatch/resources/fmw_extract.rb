# Copyright 2015 Oracle Corporation
# All Rights Reserved
#
# Cookbook Name:: fmw_opatch
# Resource:: fmw_extract
#
provides :fmw_opatch_fmw_extract, os: [ 'linux', 'solaris2']

# extracts opatch zip file
actions :extract

# Make create the default action
default_action :extract

# Opatch source file
attribute :source_file, kind_of: String, required: true
# WebLogic Operating system user
attribute :os_user, kind_of: String, required: true
# WebLogic Operating system group
attribute :os_group, kind_of: String, required: true
# tmp folder
attribute :tmp_dir, kind_of: String, required: true

state_attrs :source_file, :os_user, :os_group, :tmp_dir

attr_accessor :exists
