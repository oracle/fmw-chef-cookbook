#
# Cookbook Name:: fmw_domain
# Resource:: nodemanager_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
provides :fmw_domain_nodemanager_service, os: 'linux', platform_family: 'rhel' do |node|
  node['platform_version'] >= '7.0'
end

# Configure the nodemanager service on a RedHat family 7 host
actions :configure

# Make create the default action
default_action :configure

# user home folder, this is the folder where all the user homes are
attribute :user_home_dir, kind_of: String, required: true
# operating system user
attribute :os_user, kind_of: String, required: true
