# Copyright 2015 Oracle Corporation
# All Rights Reserved
#
# Cookbook Name:: fmw_inst
# Resource:: fmw_extract
#
provides :fmw_inst_fmw_extract, os: [ 'linux', 'solaris2']

# extracts FMW 11g,12c software
actions :extract

# Make create the default action
default_action :extract

# FMW source file
attribute :source_file, kind_of: String, required: true
# FMW source file 2
attribute :source_2_file, kind_of: String, required: false
# FMW source file 3
attribute :source_3_file, kind_of: String, required: false
# WebLogic Operating system user
attribute :os_user, kind_of: String, required: true
# WebLogic Operating system group
attribute :os_group, kind_of: String, required: true
# tmp folder
attribute :tmp_dir, kind_of: String, required: true

state_attrs :source_file, :source_2_file, :source_3_file, :os_user, :os_group, :tmp_dir

attr_accessor :exists
