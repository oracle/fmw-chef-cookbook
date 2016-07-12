#
# Cookbook Name:: fmw_domain
# Library:: helper
#
# Copyright 2015 Oracle. All Rights Reserved
#
require 'chef/mixin/shell_out'

module DomainHelper
  extend Chef::Mixin::ShellOut

  def self.listening?(command, port, column)
    cmd = shell_out!(command)
    Chef::Log.info(cmd.stdout)
    cmd.stdout.each_line.select do |l|
      l.split[column] =~ /#{port}/
    end.any?
  end

  def self.wlst_execute(version, os_user, script_file, weblogic_home_dir, weblogic_password, repository_password)
    if version == '12.2.1' or version == '12.2.1.1'
      wlst_script_dir = "#{weblogic_home_dir}/../oracle_common/common/bin"
    else
      wlst_script_dir = "#{weblogic_home_dir}/common/bin"
    end
    command = "export CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom;#{wlst_script_dir}/wlst.sh -skipWLSModuleScanning #{script_file} #{weblogic_password} #{repository_password}"
    shell_out!("su - #{os_user} -c '#{command}'", :timeout => 1200).stdout.each_line do |line|
      Chef::Log.info(line)
    end
  end

  def self.wlst_execute_windows(version, script_file, weblogic_home_dir, weblogic_password, repository_password)
    if version == '12.2.1' or version == '12.2.1.1'
      wlst_script_dir = "#{weblogic_home_dir}\\..\\oracle_common\\common\\bin"
    else
      wlst_script_dir = "#{weblogic_home_dir}\\common\\bin"
    end
    command = "#{wlst_script_dir}\\wlst.cmd -skipWLSModuleScanning #{script_file} #{weblogic_password} #{repository_password}"
    shell_out!(command, :timeout => 1200).stdout.each_line do |line|
      Chef::Log.info(line)
    end
  end

  def self.server_status(os_user, server_name, weblogic_home_dir, weblogic_user, weblogic_password, nodemanager_listen_address, nodemanager_port, domain_name, domain_dir)
    command = "export CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom;#{weblogic_home_dir}/common/bin/wlst.sh -skipWLSModuleScanning <<-EOF
      nmConnect(\"#{weblogic_user}\",\"#{weblogic_password}\",\"#{nodemanager_listen_address}\",#{nodemanager_port},\"#{domain_name}\",\"#{domain_dir}\")
      nmServerStatus(\"#{server_name}\")
      nmDisconnect()
    EOF"

    shell_out!("su - #{os_user} -c '#{command}'").stdout
  end

  def self.server_status_windows(server_name, weblogic_home_dir, weblogic_user, weblogic_password, nodemanager_listen_address, nodemanager_port, domain_name, domain_dir)
    script = 'wlstScript'
    content = "nmConnect(\"#{weblogic_user}\",\"#{weblogic_password}\",\"#{nodemanager_listen_address}\",#{nodemanager_port},\"#{domain_name}\",\"#{domain_dir}\")
nmServerStatus(\"#{server_name}\")
nmDisconnect()
"
    tmp_file = Tempfile.new([script, '.py'])
    tmp_file.write(content)
    tmp_file.close

    command = "#{weblogic_home_dir}\\common\\bin\\wlst.cmd -skipWLSModuleScanning #{tmp_file.path}"

    shell_out!(command).stdout
  end

  def self.server_control(os_user, server_name, weblogic_home_dir, weblogic_user, weblogic_password, nodemanager_listen_address, nodemanager_port, domain_name, domain_dir, action_command, check_command)
    command = "export CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/./urandom;#{weblogic_home_dir}/common/bin/wlst.sh -skipWLSModuleScanning <<-EOF
      nmConnect(\"#{weblogic_user}\",\"#{weblogic_password}\",\"#{nodemanager_listen_address}\",#{nodemanager_port},\"#{domain_name}\",\"#{domain_dir}\")
      #{action_command}
      nmDisconnect()
    EOF"

    Chef::Log.debug("su - #{os_user} -c '#{command}'")
    result = false
    shell_out!("su - #{os_user} -c '#{command}'", :timeout => 900).stdout.each_line do |line|
      Chef::Log.info(line)
      unless line.nil?
        if line.include? check_command
          result = true
        end
      end
    end
    fail if result == false
  end

  def self.server_control_windows(server_name, weblogic_home_dir, weblogic_user, weblogic_password, nodemanager_listen_address, nodemanager_port, domain_name, domain_dir, action_command, check_command)
    script = 'wlstScript'
    content = "nmConnect(\"#{weblogic_user}\",\"#{weblogic_password}\",\"#{nodemanager_listen_address}\",#{nodemanager_port},\"#{domain_name}\",\"#{domain_dir}\")
#{action_command}
nmDisconnect()
"

    tmp_file = Tempfile.new([script, '.py'])
    tmp_file.write(content)
    tmp_file.close

    command = "#{weblogic_home_dir}\\common\\bin\\wlst.cmd -skipWLSModuleScanning #{tmp_file.path}"

    result = false
    shell_out!(command, :timeout => 900).stdout.each_line do |line|
      Chef::Log.info(line)
      unless line.nil?
        if line.include? check_command
          result = true
        end
      end
    end
    fail if result == false
  end
end
