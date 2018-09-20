#
# Cookbook Name:: fmw_opatch
# Provider:: fmw_extract
#
# Copyright 2015 Oracle. All Rights Reserved
#
# fmw_extract provider for windows

provides :fmw_opatch_fmw_extract, os: 'windows' if respond_to?(:provides)

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('fmw extract provider, fmw_extract load current resource')
  @current_resource ||= Chef::ResourceResolver.resolve('fmw_opatch_fmw_extract_windows').new(new_resource.name)
  @current_resource.source_file(@new_resource.source_file)
  @current_resource.tmp_dir(@new_resource.tmp_dir)
  @current_resource.version(@new_resource.version)
  @current_resource.middleware_home_dir(@new_resource.middleware_home_dir)
  @current_resource.java_home_dir(@new_resource.java_home_dir)

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

      execute "extract #{new_resource.name} file" do
        command "#{new_resource.java_home_dir}\\bin\\jar.exe xvf #{new_resource.source_file}"
        cwd new_resource.tmp_dir
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
