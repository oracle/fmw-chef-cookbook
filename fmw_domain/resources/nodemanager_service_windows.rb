#
# Cookbook Name:: fmw_domain
# Resource:: nodemanager_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
provides :fmw_domain_nodemanager_service, os: 'windows'

# Configure the nodemanager service on Windows
actions :configure

# Make create the default action
default_action :configure

# middleware home path
attribute :middleware_home_dir, kind_of: String, required: true
# full domain dir path
attribute :domain_dir, kind_of: String, required: true
# domain name
attribute :domain_name, kind_of: String, required: true
# webLogic version
attribute :version, kind_of: String, required: true
# webLogic bin dir path
attribute :bin_dir, kind_of: String, required: true
# java home path
attribute :java_home_dir, kind_of: String, required: true
