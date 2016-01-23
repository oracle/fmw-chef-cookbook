#
# Cookbook Name:: fmw_opatch
# Provider:: fmw_extract
#
# Copyright 2015 Oracle. All Rights Reserved
#
# fmw_extract provider for windows

provides :fmw_opatch_fmw_extract, os: 'windows'

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('fmw extract provider, fmw_extract load current resource')
  @current_resource ||= Chef::Resource::FmwOpatchFmwExtractWindows.new(new_resource.name)
  @current_resource.source_file(@new_resource.source_file)
  @current_resource.tmp_dir(@new_resource.tmp_dir)
  @current_resource.version(@new_resource.version)
  @current_resource.middleware_home_dir(@new_resource.middleware_home_dir)

  @current_resource.exists = true if ::File.exist?("#{@new_resource.tmp_dir}/#{@new_resource.name}")

  @current_resource
end

# extract opatch zip on a windows host
action :extract do
  Chef::Log.info("#{@new_resource} fired the extract action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already extracted")
  else
    converge_by("Create resource #{ @new_resource }") do

      if @new_resource.version == '10.3.6'
        path = "#{@new_resource.middleware_home_dir}\\wlserver_10.3\\server\\adr"
      elsif new_resource.version == '12.1.1'
        path = "#{@new_resource.middleware_home_dir}\\wlserver_12.1\\server\\adr"
      else
        path = "#{@new_resource.middleware_home_dir}\\oracle_common\\adr"
      end

      execute "extract #{new_resource.name} file" do
        command "#{path}\\unzip.exe -o #{new_resource.source_file} -d #{new_resource.tmp_dir}"
        cwd new_resource.tmp_dir
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
