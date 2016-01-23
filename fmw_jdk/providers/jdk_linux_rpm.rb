#
# Cookbook Name:: fmw_jdk
# Provider:: jdk
#
# Copyright 2015 Oracle. All Rights Reserved
#
# jdk provider for linux and rpm as source

require 'chef/mixin/shell_out'

provides :fmw_jdk_jdk, os: 'linux', platform_family: 'rhel' do |node|
  node['fmw_jdk']['install_type'] == 'rpm'
end

def whyrun_supported?
  true
end

def initialize(*args)
  Chef::Log.info('jdk resource, jdk_linux_rpm provider initialize')
  super
  @java_home_dir = nil
  @source_file   = nil
end

def load_current_resource
  Chef::Log.info('jdk provider, jdk_linux_rpm provider load current resource')
  @current_resource ||= Chef::Resource::FmwJdkJdkLinuxRpm.new(new_resource.name)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.source_file(@new_resource.source_file)

  Chef::Log.info("#{@new_resource} checking if source_file exists")
  unless ::File.exist?(@new_resource.source_file)
    fail "source_file #{@new_resource.source_file} does not exists"
  end

  Chef::Log.info("#{@new_resource} checking the rpm parameters of source_file #{@new_resource.source_file}")
  shell_out!("rpm -qp --queryformat '%{NAME} %{VERSION}-%{RELEASE}\n' #{@new_resource.source_file}").stdout.each_line do |line|
    case line
    when /^([\w\d+_.-]+)\s([\w\d_.-]+)$/
      @package_name = $1
      Chef::Log.info("#{@new_resource} package name of source_file #{@new_resource.source_file} is #{@package_name}")
    end
  end

  Chef::Log.info("#{@new_resource} checking install state")
  rpm_status = shell_out("rpm -q --queryformat '%{NAME} %{VERSION}-%{RELEASE}\n' #{@package_name}")
  Chef::Log.info("#{@new_resource} rpm query output: #{rpm_status.stdout}")
  @current_resource.exists = true unless rpm_status.stdout.include? "package #{@package_name} is not installed"

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
      shell_out!("rpm -i #{@new_resource.source_file}")

      new_resource.updated_by_last_action(true)
    end
  end
end
