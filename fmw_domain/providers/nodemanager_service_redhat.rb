#
# Cookbook Name:: fmw_domain
# Provider:: nodemanager_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
# nodemanager_service provider for RedHat family
if respond_to?(:provides)
  provides :fmw_domain_nodemanager_service, os: 'linux', platform_family: 'rhel' do |node|
    node['platform_version'] < '7.0'
  end
end

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('nodemanager_service provider, nodemanager_service_redhat provider load current resource')
  @current_resource ||= Chef::ResourceResolver.resolve('fmw_domain_nodemanager_service_redhat').new(new_resource.name)
  @current_resource.user_home_dir(@new_resource.user_home_dir)
  @current_resource.os_user(@new_resource.os_user)
  @current_resource
end

# Configure the nodemanager service on a RedHat family 7 host
action :configure do
  Chef::Log.info("#{@new_resource} fired the configure action")
  converge_by("configure resource #{ @new_resource }") do

    execute "chkconfig #{new_resource.name}" do
      command "chkconfig --add #{new_resource.name}"
      not_if "chkconfig | /bin/grep '#{new_resource.name}'"
    end

    service new_resource.name do
      action :start
      supports status: true, restart: true, reload: true
    end
  end
end
