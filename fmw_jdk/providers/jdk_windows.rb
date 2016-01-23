#
# Cookbook Name:: fmw_jdk
# Provider:: jdk
#
# Copyright 2015 Oracle. All Rights Reserved
#
# jdk provider for windows

provides :fmw_jdk_jdk, os: 'windows'

def whyrun_supported?
  true
end

def initialize(*args)
  Chef::Log.info('jdk provider, jdk_windows provider initialize')
  super
  @java_home_dir = nil
  @source_file   = nil
end

def load_current_resource
  Chef::Log.info('jdk provider, jdk_windows provider load current resource')
  @current_resource ||= Chef::Resource::FmwJdkJdkWindows.new(new_resource.name)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.source_file(@new_resource.source_file)

  Chef::Log.info("#{@new_resource} checking if source_file exists")

  # check status of jdk
  @current_resource.exists = true if ::File.exist?(@new_resource.java_home_dir)

  @current_resource
end

# Installs a JDK executable on a Windows host
action :install do
  Chef::Log.info("#{@new_resource} fired the create action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already exists")
  else
    Chef::Log.info("#{@new_resource} doesn't exist, so lets install the jdk")
    converge_by("Create resource #{ @new_resource }") do

      parent_folder = ::File.expand_path('..', @new_resource.java_home_dir)
      java_home_dir_windows = @new_resource.java_home_dir.gsub('/', '\\\\')

      directory parent_folder do
        recursive true
        action :create
      end

      execute 'Install JDK' do
        command "#{new_resource.source_file} /s ADDLOCAL=\"ToolsFeature\" INSTALLDIR=#{java_home_dir_windows}"
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
