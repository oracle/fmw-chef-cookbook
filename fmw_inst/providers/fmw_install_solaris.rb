#
# Cookbook Name:: fmw_inst
# Provider:: fmw_install
#
# Copyright 2015 Oracle. All Rights Reserved
#
# fmw_install provider for solaris
provides :fmw_inst_fmw_install, os: 'solaris2' if respond_to?(:provides)

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('fmw install provider, fmw_install_solaris load current resource')
  @current_resource ||= Chef::Resource::FmwInstFmwInstallSolaris.new(new_resource.name)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.installer_file(@new_resource.installer_file)
  @current_resource.rsp_file(@new_resource.rsp_file)
  @current_resource.version(@new_resource.version)
  @current_resource.oracle_home_dir(@new_resource.oracle_home_dir)
  @current_resource.os_user(@new_resource.os_user)
  @current_resource.os_group(@new_resource.os_group)
  @current_resource.orainst_dir(@new_resource.orainst_dir)
  @current_resource.tmp_dir(@new_resource.tmp_dir)

  @current_resource.exists = true if ::File.exist?(@new_resource.oracle_home_dir)
  @current_resource
end

# Installs FMW software on a Solaris host
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
      orainst_dir       = @new_resource.orainst_dir
      os_group          = @new_resource.os_group
      os_user           = @new_resource.os_user

      fmw_install name do
        unix           true
        installer_file installer_file
        rsp_file       rsp_file
        java_home_dir  java_home_dir
        tmp_dir        tmp_dir
        version        version
        orainst_dir    orainst_dir
        os_group       os_group
        os_user        os_user
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
