#
# Cookbook Name:: fmw_inst
# Provider:: fmw_extract
#
# Copyright 2015 Oracle. All Rights Reserved
#
# fmw_extract provider for unix
provides :fmw_inst_fmw_extract, os: [ 'linux', 'solaris2'] if respond_to?(:provides)

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('fmw extract provider, fmw_extract load current resource')
  @current_resource ||= Chef::ResourceResolver.resolve('fmw_inst_fmw_extract').new(new_resource.name)
  @current_resource.source_file(@new_resource.source_file)
  @current_resource.source_2_file(@new_resource.source_2_file)
  @current_resource.source_3_file(@new_resource.source_3_file)
  @current_resource.os_user(@new_resource.os_user)
  @current_resource.os_group(@new_resource.os_group)
  @current_resource.tmp_dir(@new_resource.tmp_dir)

  @current_resource.exists = true if ::File.exist?("#{@new_resource.tmp_dir}/#{@new_resource.name}")

  @current_resource
end

# extract FMW software on a unix host
action :extract do
  Chef::Log.info("#{@new_resource} fired the extract action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already extracted")
  else
    converge_by("Create resource #{ @new_resource }") do

      if platform_family?('debian')
        first_run_file = "#{new_resource.tmp_dir}/aptgetrun"
        if ( !::File.exist?(first_run_file) )
             e = bash 'apt-get-update' do
                code <<-EOH
                   apt-get update
                   touch #{first_run_file}
                EOH
                ignore_failure true
                action :nothing
             end
             e.run_action(:run)
        end
        package 'unzip' do
  	      only_if { ::File.exist?(first_run_file) }
        end
      else
        package 'unzip' do
          ignore_failure true
        end
      end

      execute "extract #{new_resource.name} file 1" do
        command "unzip -o #{new_resource.source_file} -d #{new_resource.tmp_dir}/#{new_resource.name}"
        cwd new_resource.tmp_dir
        user new_resource.os_user
        group new_resource.os_group
      end

      unless @new_resource.source_2_file.nil?
        execute "extract #{new_resource.name} file 2" do
          command "unzip -o #{new_resource.source_2_file} -d #{new_resource.tmp_dir}/#{new_resource.name}"
          cwd new_resource.tmp_dir
          user new_resource.os_user
          group new_resource.os_group
        end
      end

      unless @new_resource.source_3_file.nil?
        execute "extract #{new_resource.name} file 3" do
          command "unzip -o #{new_resource.source_3_file} -d #{new_resource.tmp_dir}/#{new_resource.name}"
          cwd new_resource.tmp_dir
          user new_resource.os_user
          group new_resource.os_group
        end
      end

      new_resource.updated_by_last_action(true)
    end
  end
end
