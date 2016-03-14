# Copyright 2015 Oracle Corporation
# All Rights Reserved
#
# Cookbook Name:: fmw_inst
# Resource:: fmw_extract
#
provides :fmw_inst_fmw_extract, os: 'windows'

# extracts FMW 11g,12c software
actions :extract

# Make create the default action
default_action :extract

# WebLogic Version
attribute :version, kind_of: String, required: true
# middleware home path
attribute :middleware_home_dir, kind_of: String, required: true
# FMW source file
attribute :source_file, kind_of: String, required: true
# FMW source file 2
attribute :source_2_file, kind_of: String, required: false
# FMW source file 3
attribute :source_3_file, kind_of: String, required: false
# tmp folder
attribute :tmp_dir, kind_of: String, required: true

state_attrs :source_file, :source_2_file, :source_3_file, :tmp_dir

attr_accessor :exists
