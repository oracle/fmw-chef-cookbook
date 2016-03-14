#
# Cookbook Name:: fmw_opatch
# Provider:: opatch
#
# Copyright 2015 Oracle. All Rights Reserved
#
# opatch provider for windows
provides :fmw_opatch_opatch, os: 'windows' if respond_to?(:provides)

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('fmw extract provider, fmw_extract load current resource')
  @current_resource ||= Chef::Resource::FmwOpatchOpatch.new(new_resource.name)
  @current_resource.patch_id(@new_resource.patch_id)
  @current_resource.oracle_home_dir(@new_resource.oracle_home_dir)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.tmp_dir(@new_resource.tmp_dir)

  @current_resource.exists = false
  shell_out!("#{@new_resource.oracle_home_dir}\\OPatch\\opatch.bat lsinventory -patch_id -oh #{@new_resource.oracle_home_dir}").stdout.each_line do |line|
    unless line.nil?
      opatch = line[5, line.index(':') - 5].strip + ';' if line['Patch'] && line[': applied on']
      unless opatch.nil?
        if opatch.include? @new_resource.patch_id
          @current_resource.exists = true
        end
      end
    end
  end

  @current_resource
end

# opatch apply on a windows host
action :apply do
  Chef::Log.info("#{@new_resource} fired the apply action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already patched")
  else
    converge_by("Create resource #{ @new_resource }") do
      result = false
      shell_out!("#{@new_resource.oracle_home_dir}\\OPatch\\opatch.bat apply -silent -jre #{@new_resource.java_home_dir}/jre -oh #{@new_resource.oracle_home_dir} #{@new_resource.tmp_dir}/#{@new_resource.patch_id}", :timeout => 1200).stdout.each_line do |line|
        unless line.nil?
          Chef::Log.info(line)
          if line.include? 'OPatch completed' or line.include? 'OPatch succeeded'
            result = true
          end
        end
      end
      fail if result == false

      new_resource.updated_by_last_action(true)
    end
  end
end

# opatch rollback on a windows host
action :rollback do
  Chef::Log.info("#{@new_resource} fired the rollback action")
  if @current_resource.exists
    converge_by("Rollback resource #{ @new_resource }") do
      result = false
      shell_out!("#{@new_resource.oracle_home_dir}\\OPatch\\opatch rollback -id #{@new_resource.patch_id} -silent -jre #{@new_resource.java_home_dir}/jre -oh #{@new_resource.oracle_home_dir}", :timeout => 1200).stdout.each_line do |line|
        unless line.nil?
          Chef::Log.info(line)
          if line.include? 'OPatch completed' or line.include? 'OPatch succeeded'
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
