#
# Cookbook Name:: fmw_jdk
# Provider:: jdk
#
# Copyright 2015 Oracle. All Rights Reserved
#
# jdk provider for solaris

if respond_to?(:provides)
  provides :fmw_jdk_jdk, os: 'solaris2' do |node|
    node['fmwjdk']['install_type'] == 'tar.Z'
  end
end

def whyrun_supported?
  true
end

def initialize(*args)
  Chef::Log.info('jdk provider, jdk_solaris_z provider initialize')
  super
  @java_home_dir   = nil
  @source_file     = nil
  @source_x64_file = nil
end

def load_current_resource
  Chef::Log.info('jdk provider, jdk_solaris_z provider load current resource')
  @current_resource ||= Chef::Resource::FmwJdkJdkSolarisZ.new(new_resource.name)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.source_file(@new_resource.source_file)
  @current_resource.source_x64_file(@new_resource.source_x64_file)

  # check status of jdk
  @current_resource.exists = true if ::File.exist?(@new_resource.java_home_dir)
  @current_resource
end

# Installs a JDK tar.Z SVR4 package source file on a Solaris host
action :install do
  Chef::Log.info("#{@new_resource} fired the create action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already exists")
  else
    Chef::Log.info("#{@new_resource} doesn't exist, so lets install the jdk")
    converge_by("Create resource #{ @new_resource }") do

      if @new_resource.source_file.include?('jdk-8')
        package_name = 'SUNWj8rt'
        package_x64_name = ''
      else
        package_name = 'SUNWj7rt'
        package_x64_name = 'SUNWj7rtx'
      end

      directory '/tmp/java' do
        action :create
        mode '0775'
      end

      cookbook_file '/tmp/java/admin.rsp' do
        source 'solaris_admin.rsp'
        action :create
        mode '0775'
      end

      execute 'uncompress JDK SVR4 packages' do
        command "zcat #{new_resource.source_file}|tar -xvpf -"
        cwd '/tmp/java'
        creates "/tmp/java/#{package_name}"
        user 'root'
        group 'root'
      end

      execute 'install JDK SVR4 packages' do
        command "pkgadd -a /tmp/java/admin.rsp -d /tmp/java #{package_name}"
      end

      unless @new_resource.source_x64_file.nil?
        execute 'uncompress JDK x64 SVR4 packages' do
          command "zcat #{new_resource.source_x64_file}|tar -xvpf -"
          cwd '/tmp/java'
          creates "/tmp/java/#{package_x64_name}"
          user 'root'
          group 'root'
        end

        execute 'install JDK x64 SVR4 packages' do
          command "pkgadd -a /tmp/java/admin.rsp -d /tmp/java #{package_x64_name}"
        end
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
