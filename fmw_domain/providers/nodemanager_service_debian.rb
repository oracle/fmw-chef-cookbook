#
# Cookbook Name:: fmw_domain
# Provider:: nodemanager_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
# nodemanager_service provider for Debian family
provides :fmw_domain_nodemanager_service, os: 'linux', platform_family: 'debian' if respond_to?(:provides)

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('nodemanager_service provider, nodemanager_service_redhat provider load current resource')
  @current_resource ||= Chef::ResourceResolver.resolve('fmw_domain_nodemanager_service_debian').new(new_resource.name)
  @current_resource.user_home_dir(@new_resource.user_home_dir)
  @current_resource.os_user(@new_resource.os_user)
  @current_resource
end

# Configure the nodemanager service on a Debian family host
action :configure do
  Chef::Log.info("#{@new_resource} fired the configure action")
  converge_by("configure resource #{ @new_resource }") do

    execute "update-rc.d #{new_resource.name}" do
      command "update-rc.d #{new_resource.name} defaults"
      not_if "ls /etc/rc3.d/*${scriptName} | /bin/grep '#{new_resource.name}'"
    end

    service new_resource.name do
      action :start
      supports status: true, restart: true, reload: true
    end
  end
end
