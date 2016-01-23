#
# Cookbook Name:: fmw_bsu
# Provider:: bsu
#
# Copyright 2015 Oracle. All Rights Reserved
#
# bsu provider for windows
provides :fmw_bsu_bsu, os: 'windows'

require 'chef/mixin/shell_out'

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('bsu provider, bsu load current resource')
  @current_resource ||= Chef::Resource::FmwBsuBsuWindows.new(new_resource.name)
  @current_resource.patch_id(@new_resource.patch_id)
  @current_resource.middleware_home_dir(@new_resource.middleware_home_dir)

  @current_resource.exists = false
  shell_out!("#{@new_resource.middleware_home_dir}\\utils\\bsu\\bsu.cmd -view -status=applied -prod_dir=#{@new_resource.middleware_home_dir}\\wlserver_10.3 -verbose", cwd: "#{@new_resource.middleware_home_dir}\\utils\\bsu").stdout.each_line do |line|
    Chef::Log.debug(line)
    unless line.nil?
      if line.include? @new_resource.patch_id
        @current_resource.exists = true
      end
    end
  end

  @current_resource
end

# install bsu patch on a windows host
action :install do
  Chef::Log.info("#{@new_resource} fired the install action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already patched")
  else
    converge_by("Create resource #{ @new_resource }") do
      result = false
      shell_out!("#{@new_resource.middleware_home_dir}\\utils\\bsu\\bsu.cmd -install -patchlist=#{@new_resource.patch_id} -prod_dir=#{@new_resource.middleware_home_dir}\\wlserver_10.3 -verbose", cwd: "#{@new_resource.middleware_home_dir}\\utils\\bsu", :timeout => 1200).stdout.each_line do |line|
        Chef::Log.info(line)
        unless line.nil?
          if line.include? 'Result: Success'
            result = true
          end
        end
      end
      fail if result == false

      new_resource.updated_by_last_action(true)
    end
  end
end

# remove bsu patch on a windows host
action :remove do
  Chef::Log.info("#{@new_resource} fired the remove action")
  if @current_resource.exists
    converge_by("Rollback resource #{ @new_resource }") do
      result = false
      result = false
      shell_out!("#{@new_resource.middleware_home_dir}\\utils\\bsu\\bsu.cmd -remove -patchlist=#{@new_resource.patch_id} -prod_dir=#{@new_resource.middleware_home_dir}\\wlserver_10.3 -verbose", cwd: "#{@new_resource.middleware_home_dir}\\utils\\bsu", :timeout => 1200).stdout.each_line do |line|
        Chef::Log.info(line)
        unless line.nil?
          if line.include? 'Result: Success'
            result = true
          end
        end
      end
      fail if result == false

      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.info("#{@new_resource} is not applied")
  end
end
