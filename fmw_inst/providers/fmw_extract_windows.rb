#
# Cookbook Name:: fmw_inst
# Provider:: fmw_extract
#
# Copyright 2015 Oracle. All Rights Reserved
#
# fmw_extract provider for windows

provides :fmw_inst_fmw_extract, os: 'windows'

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('fmw extract provider, fmw_extract load current resource')
  @current_resource ||= Chef::Resource::FmwInstFmwExtractWindows.new(new_resource.name)
  @current_resource.source_file(@new_resource.source_file)
  @current_resource.source_2_file(@new_resource.source_2_file)
  @current_resource.source_3_file(@new_resource.source_3_file)
  @current_resource.version(@new_resource.version)
  @current_resource.middleware_home_dir(@new_resource.middleware_home_dir)
  @current_resource.tmp_dir(@new_resource.tmp_dir)

  @current_resource.exists = true if ::File.exist?("#{@new_resource.tmp_dir}/#{@new_resource.name}")

  @current_resource
end

# extract FMW software on a windows host
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

      execute "extract #{new_resource.name} file 1" do
        command "#{path}\\unzip.exe -o #{new_resource.source_file} -d #{new_resource.tmp_dir}/#{new_resource.name}"
        cwd new_resource.tmp_dir
      end

      unless @new_resource.source_2_file.nil?
        execute "extract #{new_resource.name} file 2" do
          command "#{path}\\unzip.exe -o #{new_resource.source_2_file} -d #{new_resource.tmp_dir}/#{new_resource.name}"
          cwd new_resource.tmp_dir
        end
      end

      unless @new_resource.source_3_file.nil?
        execute "extract #{new_resource.name} file 3" do
          command "#{path}\\unzip.exe -o #{new_resource.source_3_file} -d #{new_resource.tmp_dir}/#{new_resource.name}"
          cwd new_resource.tmp_dir
        end
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
