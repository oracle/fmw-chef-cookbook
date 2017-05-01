#
# Cookbook Name:: fmw_domain
# Provider:: adminserver
#
# Copyright 2015 Oracle. All Rights Reserved
#
# Adminserver control on a windows host
provides :fmw_domain_adminserver, os: 'windows' if respond_to?(:provides)

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('adminserver provider, adminserver_windows provider load current resource')
  @current_resource ||= Chef::ResourceResolver.resolve('fmw_domain_adminserver_windows').new(new_resource.name)
  @current_resource.domain_dir(@new_resource.domain_dir)
  @current_resource.domain_name(@new_resource.domain_name)
  @current_resource.adminserver_name(@new_resource.adminserver_name)
  @current_resource.weblogic_home_dir(@new_resource.weblogic_home_dir)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.weblogic_user(@new_resource.weblogic_user)
  @current_resource.weblogic_password(@new_resource.weblogic_password)
  @current_resource.nodemanager_listen_address(@new_resource.nodemanager_listen_address)
  @current_resource.nodemanager_port(@new_resource.nodemanager_port)

  @current_resource.started = false
  output = DomainHelper.server_status_windows(@new_resource.adminserver_name, @new_resource.weblogic_home_dir, @new_resource.weblogic_user, @new_resource.weblogic_password, @new_resource.nodemanager_listen_address, @new_resource.nodemanager_port, @new_resource.domain_name, @new_resource.domain_dir)
  output.each_line do |line|
    Chef::Log.info(line)
    unless line.nil?
      if line.include? 'RUNNING'
        @current_resource.started = true
      end
    end
  end

  @current_resource
end

# Start the AdminServer
action :start do
  Chef::Log.info("#{@new_resource} fired the start action")
  if @current_resource.started
    Chef::Log.info("#{@new_resource} already started")
  else
    converge_by("Create resource #{ @new_resource }") do
      DomainHelper.server_control_windows(@new_resource.adminserver_name, @new_resource.weblogic_home_dir, @new_resource.weblogic_user, @new_resource.weblogic_password, @new_resource.nodemanager_listen_address, @new_resource.nodemanager_port, @new_resource.domain_name, @new_resource.domain_dir, "nmStart(\"#{new_resource.adminserver_name}\")", 'Successfully started server')
      new_resource.updated_by_last_action(true)
    end
  end
end

# Stop the AdminServer
action :stop do
  Chef::Log.info("#{@new_resource} fired the stop action")
  if @current_resource.started
    converge_by("Create resource #{ @new_resource }") do
      DomainHelper.server_control_windows(@new_resource.adminserver_name, @new_resource.weblogic_home_dir, @new_resource.weblogic_user, @new_resource.weblogic_password, @new_resource.nodemanager_listen_address, @new_resource.nodemanager_port, @new_resource.domain_name, @new_resource.domain_dir, "nmKill(\"#{new_resource.adminserver_name}\")", 'Successfully killed server')
      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.info("#{@new_resource} already stopped")
  end
end

# Stop the AdminServer
action :restart do
  Chef::Log.info("#{@new_resource} fired the restart action")
  if @current_resource.started
    converge_by("Create resource #{ @new_resource }") do
      DomainHelper.server_control_windows(@new_resource.adminserver_name, @new_resource.weblogic_home_dir, @new_resource.weblogic_user, @new_resource.weblogic_password, @new_resource.nodemanager_listen_address, @new_resource.nodemanager_port, @new_resource.domain_name, @new_resource.domain_dir, "nmKill(\"#{new_resource.adminserver_name}\")", 'Successfully killed server')
      DomainHelper.server_control_windows(@new_resource.adminserver_name, @new_resource.weblogic_home_dir, @new_resource.weblogic_user, @new_resource.weblogic_password, @new_resource.nodemanager_listen_address, @new_resource.nodemanager_port, @new_resource.domain_name, @new_resource.domain_dir, "nmStart(\"#{new_resource.adminserver_name}\")", 'Successfully started server')
      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.info("#{@new_resource} already stopped, will only start the AdminServer")
    converge_by("Create resource #{ @new_resource }") do
      DomainHelper.server_control_windows(@new_resource.adminserver_name, @new_resource.weblogic_home_dir, @new_resource.weblogic_user, @new_resource.weblogic_password, @new_resource.nodemanager_listen_address, @new_resource.nodemanager_port, @new_resource.domain_name, @new_resource.domain_dir, "nmStart(\"#{new_resource.adminserver_name}\")", 'Successfully started server')
      new_resource.updated_by_last_action(true)
    end
  end
end
