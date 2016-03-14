#
# Cookbook Name:: fmw_wls
# Provider:: wls
#
# Copyright 2015 Oracle. All Rights Reserved
#
# wls provider for solaris
provides :fmw_wls_wls, os: 'solaris2' if respond_to?(:provides)

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('wls provider, wls_solaris load current resource')
  @current_resource ||= Chef::Resource::FmwWlsWlsSolaris.new(new_resource.name)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.source_file(@new_resource.source_file)
  @current_resource.version(@new_resource.version)
  @current_resource.middleware_home_dir(@new_resource.middleware_home_dir)
  @current_resource.os_user(@new_resource.os_user)
  @current_resource.os_group(@new_resource.os_group)
  @current_resource.ora_inventory_dir(@new_resource.ora_inventory_dir)
  @current_resource.orainst_dir(@new_resource.orainst_dir)
  @current_resource.tmp_dir(@new_resource.tmp_dir)
  @current_resource.install_type(@new_resource.install_type)

  Chef::Log.info("#{@new_resource} checking if source_file exists")
  unless ::File.exist?(@new_resource.source_file)
    fail "source_file #{@new_resource.source_file} does not exists"
  end

  @current_resource.exists = true if ::File.exist?(@new_resource.name)
  @current_resource
end

# Installs WebLogic on a Solaris host
action :install do
  Chef::Log.info("#{@new_resource} fired the create action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already exists")
  else
    Chef::Log.info("#{@new_resource} doesn't exist, so lets install weblogic")
    converge_by("Create resource #{ @new_resource }") do

      orainst_dir         = @new_resource.orainst_dir
      ora_inventory_dir   = @new_resource.ora_inventory_dir
      os_group            = @new_resource.os_group
      os_user             = @new_resource.os_user
      middleware_home_dir = @new_resource.name
      version             = @new_resource.version
      tmp_dir             = @new_resource.tmp_dir
      java_home_dir       = @new_resource.java_home_dir
      source_file         = @new_resource.source_file
      install_type        = @new_resource.install_type

      # create the oracle orainst directory
      directory new_resource.orainst_dir do
        mode      0755
        recursive true
        action    :create
      end

      ora_inst 'solaris' do
        orainst_dir       orainst_dir
        ora_inventory_dir ora_inventory_dir
        os_group          os_group
        os_user           os_user
      end

      parent_folder = ::File.expand_path('..', middleware_home_dir)

      directory parent_folder do
        mode      0775
        recursive true
        owner     os_user
        group     os_group
        action    :create
      end

      # make sure the middleware directory exists
      directory new_resource.middleware_home_dir do
        mode   0775
        owner  os_user
        group  os_group
        action :create
      end

      if ['12.2.1', '12.1.3', '12.1.2'].include?(version)
        template = 'wls_12c.rsp'
      elsif ['10.3.6', '12.1.1'].include?(version)
        template = 'wls_11g.rsp'
      end

      wls_template 'solaris' do
        middleware_home_dir middleware_home_dir
        template            template
        install_type        install_type
        tmp_dir             tmp_dir
        os_group            os_group
        os_user             os_user
      end

      wls_install 'solaris' do
        middleware_home_dir middleware_home_dir
        java_home_dir       java_home_dir
        tmp_dir             tmp_dir
        version             version
        os_group            os_group
        os_user             os_user
        source_file         source_file
        template            template
        orainst_dir         orainst_dir
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
