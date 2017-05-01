#
# Cookbook Name:: fmw_domain
# Provider:: nodemanager_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
# nodemanager_service provider for Solaris
provides :fmw_domain_nodemanager_service, os: 'solaris2' if respond_to?(:provides)

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('nodemanager_service provider, nodemanager_service_solaris provider load current resource')
  @current_resource ||= Chef::ResourceResolver.resolve('fmw_domain_nodemanager_service_solaris').new(new_resource.name)
  @current_resource.bin_dir(@new_resource.bin_dir)
  @current_resource.os_user(@new_resource.os_user)
  @current_resource.tmp_dir(@new_resource.tmp_dir)
  @current_resource.service_name(@new_resource.service_name)
  @current_resource
end

# Configure the nodemanager service on a RedHat family 7 host
action :configure do
  Chef::Log.info("#{@new_resource} fired the configure action")
  converge_by("configure resource #{ @new_resource }") do

    # add solaris smf script to the right location
    template "/etc/#{new_resource.service_name}" do
      source 'nodemanager/nodemanager_solaris'
      mode 0755
      variables(nodemanager_bin_path: new_resource.bin_dir,
                os_user:              new_resource.os_user)
    end

    # add solaris smf template
    template "#{new_resource.tmp_dir}/nodemanager_smf.xml" do
      source 'nodemanager/nodemanager_smf.xml'
      mode 0755
      variables(service_name: new_resource.service_name)
    end

    execute "svccfg #{new_resource.service_name} import" do
      command "svccfg -v import #{new_resource.tmp_dir}/nodemanager_smf.xml"
      not_if "svccfg list | grep #{new_resource.service_name}"
    end

    service new_resource.name do
      action :start
      supports restart: true
    end

  end
end
