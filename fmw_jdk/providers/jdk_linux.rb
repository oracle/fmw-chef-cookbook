#
# Cookbook Name:: fmw_jdk
# Provider:: jdk
#
# Copyright 2015 Oracle. All Rights Reserved
#
# jdk provider for linux and rpm as source

provides :fmw_jdk_jdk, os: 'linux' do |node|
  node['fmw_jdk']['install_type'] == 'tar.gz'
end

def whyrun_supported?
  true
end

def initialize(*args)
  Chef::Log.info('jdk provider, jdk_linux provider initialize')
  super
  @java_home_dir = nil
  @source_file   = nil
end

def load_current_resource
  Chef::Log.info('jdk provider, jdk_linux provider load current resource')
  @current_resource ||= Chef::Resource::FmwJdkJdkLinux.new(new_resource.name)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.source_file(@new_resource.source_file)

  @current_resource.exists = true if ::File.exist?(@new_resource.java_home_dir)

  @current_resource
end

# Installs a JDK rpm on a Linux host
action :install do
  Chef::Log.info("#{@new_resource} fired the create action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already exists")
  else
    Chef::Log.info("#{@new_resource} doesn't exist, so lets install the jdk")
    converge_by("Create resource #{ @new_resource }") do

      directory @new_resource.java_home_dir do
        owner 'root'
        group 'root'
        mode '0755'
        recursive true
        action :create
      end

      parent_folder = ::File.expand_path('..', @new_resource.java_home_dir)

      execute 'Unpack JDK' do
        command "tar xzvf #{new_resource.source_file} --directory #{parent_folder}"
      end

      if node['platform_family'].include?('rhel')
        statement = 'alternatives'
      else
        statement = 'update-alternatives'
      end

      %w( java javac javaws keytool ).each do |file|
        execute "#{statement} #{file}" do
          command "#{statement} --install /usr/bin/#{file} #{file} #{new_resource.java_home_dir}/bin/#{file} 1"
        end
      end

      execute 'chown java_home_dir' do
        command "chown -R root:root #{new_resource.java_home_dir}"
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
