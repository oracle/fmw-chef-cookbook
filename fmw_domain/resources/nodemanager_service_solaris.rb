#
# Cookbook Name:: fmw_domain
# Resource:: nodemanager_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
provides :fmw_domain_nodemanager_service, os: 'solaris2'

# Configure the nodemanager service on Solaris
actions :configure

# Make create the default action
default_action :configure

# webLogic bin dir path
attribute :bin_dir, kind_of: String, required: true
# operating system user
attribute :os_user, kind_of: String, required: true
# tmp folder
attribute :tmp_dir, kind_of: String, required: true
# service_name to make this unique
attribute :service_name, kind_of: String, required: true
