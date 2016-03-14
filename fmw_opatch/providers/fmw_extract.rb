#
# Cookbook Name:: fmw_opatch
# Provider:: fmw_extract
#
# Copyright 2015 Oracle. All Rights Reserved
#
# fmw_extract provider for unix
provides :fmw_opatch_fmw_extract, os: [ 'linux', 'solaris2'] if respond_to?(:provides)

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('fmw extract provider, fmw_extract load current resource')
  @current_resource ||= Chef::Resource::FmwOpatchFmwExtract.new(new_resource.name)
  @current_resource.source_file(@new_resource.source_file)
  @current_resource.os_user(@new_resource.os_user)
  @current_resource.os_group(@new_resource.os_group)
  @current_resource.tmp_dir(@new_resource.tmp_dir)

  @current_resource.exists = true if ::File.exist?("#{@new_resource.tmp_dir}/#{@new_resource.name}")
  @current_resource
end

# extract opatch zip on a unix host
action :extract do
  Chef::Log.info("#{@new_resource} fired the extract action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already extracted")
  else
    converge_by("Create resource #{@new_resource}") do
      package 'unzip' do
        action :install
      end

      execute "extract #{new_resource.name} file" do
        command "unzip -o #{new_resource.source_file} -d #{new_resource.tmp_dir}"
        cwd new_resource.tmp_dir
        user new_resource.os_user
        group new_resource.os_group
      end
      new_resource.updated_by_last_action(true)
    end
  end
end
