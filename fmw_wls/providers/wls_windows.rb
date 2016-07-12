#
# Cookbook Name:: fmw_wls
# Provider:: wls
#
# Copyright 2015 Oracle. All Rights Reserved
#
# wls provider for windows
provides :fmw_wls_wls, os: 'windows' if respond_to?(:provides)

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('wls provider, wls_windows load current resource')
  @current_resource ||= Chef::Resource::FmwWlsWlsWindows.new(new_resource.name)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.source_file(@new_resource.source_file)
  @current_resource.version(@new_resource.version)
  @current_resource.middleware_home_dir(@new_resource.middleware_home_dir)
  @current_resource.ora_inventory_dir(@new_resource.ora_inventory_dir)
  @current_resource.tmp_dir(@new_resource.tmp_dir)
  @current_resource.install_type(@new_resource.install_type)

  Chef::Log.info("#{@new_resource} checking if source_file exists")
  unless ::File.exist?(@new_resource.source_file)
    fail "source_file #{@new_resource.source_file} does not exists"
  end

  @current_resource.exists = true if ::File.exist?(@new_resource.name)
  @current_resource
end

# Installs WebLogic on a Windows host
action :install do
  Chef::Log.info("#{@new_resource} fired the create action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already exists")
  else
    Chef::Log.info("#{@new_resource} doesn't exist, so lets install weblogic")
    converge_by("Create resource #{ @new_resource }") do


      ora_inventory_dir   = @new_resource.ora_inventory_dir
      middleware_home_dir = @new_resource.name
      version             = @new_resource.version
      tmp_dir             = @new_resource.tmp_dir
      java_home_dir       = @new_resource.java_home_dir
      source_file         = @new_resource.source_file
      install_type        = @new_resource.install_type

      registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Oracle' do
        values [{ name: 'inst_loc', type: :string, data: ora_inventory_dir }]
        action :create_if_missing
      end

      if ['12.2.1', '12.2.1.1', '12.1.3', '12.1.2'].include?(version)
        template = 'wls_12c.rsp'
      elsif ['10.3.6', '12.1.1'].include?(version)
        template = 'wls_11g.rsp'
      end

      wls_template 'windows' do
        unix                false
        middleware_home_dir middleware_home_dir
        template            template
        install_type        install_type
        tmp_dir             tmp_dir
      end

      wls_install 'windows' do
        unix                false
        middleware_home_dir middleware_home_dir
        java_home_dir       java_home_dir
        tmp_dir             tmp_dir
        version             version
        source_file         source_file
        template            template
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
