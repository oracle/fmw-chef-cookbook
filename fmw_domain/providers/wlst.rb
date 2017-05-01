#
# Cookbook Name:: fmw_domain
# Provider:: wlst
#
# Copyright 2015 Oracle. All Rights Reserved
#
# Adminserver control on a unix host
provides :fmw_domain_wlst, os: [ 'linux', 'solaris2'] if respond_to?(:provides)

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('wlst provider, wlst provider load current resource')
  @current_resource ||= Chef::ResourceResolver.resolve('fmw_domain_wlst').new(new_resource.name)
  @current_resource.version(@new_resource.version)
  @current_resource.script_file(@new_resource.script_file)
  @current_resource.middleware_home_dir(@new_resource.middleware_home_dir)
  @current_resource.weblogic_home_dir(@new_resource.weblogic_home_dir)
  @current_resource.os_user(@new_resource.os_user)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.weblogic_user(@new_resource.weblogic_user)
  @current_resource.weblogic_password(@new_resource.weblogic_password)
  @current_resource.repository_password(@new_resource.repository_password)
  @current_resource.tmp_dir(@new_resource.tmp_dir)

  @current_resource
end

# execute the WLST script
action :execute do
  Chef::Log.info("#{@new_resource} execute the WLST script")
  converge_by("Create resource #{ @new_resource }") do
    DomainHelper.wlst_execute(@new_resource.version, @new_resource.os_user, @new_resource.script_file, @new_resource.weblogic_home_dir, @new_resource.weblogic_password, @new_resource.repository_password)
    new_resource.updated_by_last_action(true)
  end
end
