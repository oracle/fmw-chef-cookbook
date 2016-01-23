#
# Cookbook Name:: fmw_jdk
# Resource:: rng_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
provides :fmw_jdk_rng_service, os: 'linux', platform_family: 'debian'

# Configure the rng service on a Debian family host
actions :configure

# Make create the default action
default_action :configure
