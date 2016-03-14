#
# Cookbook Name:: fmw_inst
# Provider:: fmw_install
#
# Copyright 2015 Oracle. All Rights Reserved
#
# fmw_install provider for windows
provides :fmw_inst_fmw_install, os: 'windows' if respond_to?(:provides)

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('fmw install provider, fmw_install_windows load current resource')
  @current_resource ||= Chef::Resource::FmwInstFmwInstallWindows.new(new_resource.name)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.installer_file(@new_resource.installer_file)
  @current_resource.rsp_file(@new_resource.rsp_file)
  @current_resource.version(@new_resource.version)
  @current_resource.oracle_home_dir(@new_resource.oracle_home_dir)
  @current_resource.tmp_dir(@new_resource.tmp_dir)

  @current_resource.exists = true if ::File.exist?(@new_resource.oracle_home_dir)
  @current_resource
end

# Installs FMW software on a Windows host
action :install do
  Chef::Log.info("#{@new_resource} fired the create action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already exists")
  else
    Chef::Log.info("#{@new_resource} doesn't exist, so lets install FMW")
    converge_by("Create resource #{ @new_resource }") do

      name              = @new_resource.name
      version           = @new_resource.version
      tmp_dir           = @new_resource.tmp_dir
      java_home_dir     = @new_resource.java_home_dir
      installer_file    = @new_resource.installer_file
      rsp_file          = @new_resource.rsp_file

      fmw_install name do
        unix                false
        installer_file      installer_file
        rsp_file            rsp_file
        java_home_dir       java_home_dir
        tmp_dir             tmp_dir
        version             version
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
