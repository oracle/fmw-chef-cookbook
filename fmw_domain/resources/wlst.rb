#
# Cookbook Name:: fmw_domain
# Resource:: wlst
#
# Copyright 2015 Oracle. All Rights Reserved
#
provides :fmw_domain_wlst, os: [ 'linux', 'solaris2']

# WLST action on a unix host
actions :execute

# Make create the default action
default_action :execute

# WebLogic Version
attribute :version, kind_of: String, required: true
# script file
attribute :script_file, kind_of: String, required: true
# middleware home path
attribute :middleware_home_dir, kind_of: String, required: true
# weblogic home path
attribute :weblogic_home_dir, kind_of: String, required: true
# operating system user
attribute :os_user, kind_of: String, required: true
# java home path
attribute :java_home_dir, kind_of: String, required: true
# weblogic administration user
attribute :weblogic_user, kind_of: [String, NilClass], default: nil
# weblogic password
attribute :weblogic_password, kind_of: [String, NilClass], default: 'xxx'
# repository password
attribute :repository_password, kind_of: [String, NilClass], default: 'xxx'
# temp directory
attribute :tmp_dir, kind_of: String, required: true
