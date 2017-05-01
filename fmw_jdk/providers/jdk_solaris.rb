#
# Cookbook Name:: fmw_jdk
# Provider:: jdk
#
# Copyright 2015 Oracle. All Rights Reserved
#
# jdk provider for solaris

if respond_to?(:provides)
  provides :fmw_jdk_jdk, os: 'solaris2' do |node|
    node['fmwjdk']['install_type'] == 'tar.gz'
  end
end

def whyrun_supported?
  true
end

def initialize(*args)
  Chef::Log.info('jdk provider, jdk_solaris provider initialize')
  super
  @java_home_dir   = nil
  @source_file     = nil
  @source_x64_file = nil
end

def load_current_resource
  Chef::Log.info('jdk provider, jdk_solaris provider load current resource')
  @current_resource ||= Chef::ResourceResolver.resolve(:fmw_jdk_jdk_solaris).new(new_resource.name)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.source_file(@new_resource.source_file)
  @current_resource.source_x64_file(@new_resource.source_x64_file)

  # check status of jdk
  @current_resource.exists = true if ::File.exist?(@new_resource.java_home_dir)

  @current_resource
end

# Installs a JDK tar.gz source file on a Solaris host
action :install do
  Chef::Log.info("#{@new_resource} fired the create action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already exists")
  else
    Chef::Log.info("#{@new_resource} doesn't exist, so lets install the jdk")
    converge_by("Create resource #{ @new_resource }") do

      directory @new_resource.java_home_dir do
        owner 'root'
        group 'bin'
        mode '0755'
        recursive true
        action :create
      end

      parent_folder = ::File.expand_path('..', @new_resource.java_home_dir)

      execute 'uncompress JDK' do
        command "gzip -dc #{new_resource.source_file} | tar xf -"
        cwd parent_folder
      end

      unless @new_resource.source_x64_file.nil?
        execute 'uncompress JDK x64 extensions' do
          command "gzip -dc #{new_resource.source_x64_file} | tar xf -"
          cwd parent_folder
        end
      end

      %w( java javac javaws keytool ).each do |file|
        link "/usr/bin/#{file}" do
          to "#{new_resource.java_home_dir}/bin/#{file}"
        end
      end

      link '/usr/java' do
        to new_resource.java_home_dir
      end

      link '/usr/jdk/latest' do
        to new_resource.java_home_dir
      end

      execute 'chown java_home_dir' do
        command "chown -R root:bin #{new_resource.java_home_dir}"
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
