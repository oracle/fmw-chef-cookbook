# Copyright 2015 Oracle Corporation
# All Rights Reserved
#
# Cookbook Name:: fmw_opatch
# Resource:: fmw_extract
#
provides :fmw_opatch_fmw_extract, os: 'windows'

# extracts opatch zip file
actions :extract

# Make create the default action
default_action :extract

# WebLogic Version
attribute :version, kind_of: String, required: true
# middleware home path
attribute :middleware_home_dir, kind_of: String, required: true
# Java home folder
attribute :java_home_dir, kind_of: String, required: true
# Opatch source file
attribute :source_file, kind_of: String, required: true
# tmp folder
attribute :tmp_dir, kind_of: String, required: true

state_attrs :source_file, :tmp_dir

attr_accessor :exists
