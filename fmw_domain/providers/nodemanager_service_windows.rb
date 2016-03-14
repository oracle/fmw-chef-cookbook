#
# Cookbook Name:: fmw_domain
# Provider:: nodemanager_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
# nodemanager_service provider for windows
provides :fmw_domain_nodemanager_service, os: 'windows' if respond_to?(:provides)

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('nodemanager_service provider, nodemanager_service_windows provider load current resource')
  @current_resource ||= Chef::Resource::FmwDomainNodemanagerServiceWindows.new(new_resource.name)
  @current_resource.middleware_home_dir(@new_resource.middleware_home_dir)
  @current_resource.domain_dir(@new_resource.domain_dir)
  @current_resource.domain_name(@new_resource.domain_name)
  @current_resource.version(@new_resource.version)
  @current_resource.bin_dir(@new_resource.bin_dir)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource
end

# Configure the nodemanager service on Windows
action :configure do
  Chef::Log.info("#{@new_resource} fired the configure action")
  converge_by("configure resource #{ @new_resource }") do

    exists = false
    last_char = 0
    first_char = 0
    service_name = nil

    if new_resource.version == '10.3.6'
      service_check_name = 'Oracle WebLogic NodeManager'
    else
      service_check_name = "Oracle Weblogic #{new_resource.domain_name} NodeManager"
    end

    # check the existence and the service name
    shell_out!("wmic service where \"name like '#{service_check_name}%'\"").stdout.each_line do |line|
      Chef::Log.debug(line)
      unless line.nil?
        last_char  = line.index('CheckPoint') if line.include? 'CheckPoint'
        first_char = line.index('Caption') if line.include? 'Caption'
        Chef::Log.debug("-- #{first_char} #{last_char}")
        if line.include? service_check_name
          service_name = line[first_char..(last_char - 1)].strip
          Chef::Log.info("--- #{first_char} #{last_char} #{service_name}")
          exists = true
        end
      end
    end

    if exists == false
      if new_resource.version == '10.3.6'
        execute 'add NodeManager service 11g' do
          command 'installNodeMgrSvc.cmd'
          cwd new_resource.bin_dir
          environment ({ 'CLASSPATH' => "#{new_resource.middleware_home_dir}\\wlserver_10.3\\server\\lib\\weblogic.jar",
                         'JAVA_HOME' => new_resource.java_home_dir })
        end
      else
        execute 'add NodeManager service 12c' do
          command 'installNodeMgrSvc.cmd'
          cwd new_resource.bin_dir
          environment ({ 'JAVA_OPTIONS' => "-Dohs.product.home=#{new_resource.middleware_home_dir} -Dweblogic.RootDirectory=#{new_resource.domain_dir}",
                         'JAVA_HOME'    => new_resource.java_home_dir,
                         'MW_HOME'      => new_resource.middleware_home_dir })
        end
      end
      # do it in a block so it executed after the adding the nodemanager service
      ruby_block 'check the real name and start the nodemanager service' do
        block do
          # check the name again
          last_char = 0
          first_char = 0
          service_name = nil

          shell_out!("wmic service where \"name like '#{service_check_name}%'\"").stdout.each_line do |line|
            unless line.nil?
              last_char = line.index('CheckPoint') if line.include? 'CheckPoint'
              first_char = line.index('Caption') if line.include? 'Caption'
              if line.include? service_check_name
                service_name = line[first_char..(last_char - 1)].strip
                shell_out!("sc start \"#{service_name}\"")
                Chef::Log.info(service_name)
              end
            end
          end
        end
      end
    else
      # service already exists, just start it
      service service_name do
        action :start
        supports status: true, restart: true, reload: true
      end
    end

  end
end
