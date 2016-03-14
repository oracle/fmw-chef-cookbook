#
# Cookbook Name:: fmw_rcu
# Provider:: repository
#
# Copyright 2015 Oracle. All Rights Reserved
#
# fmw_extract provider for unix
provides :fmw_rcu_repository, os: [ 'linux', 'solaris2'] if respond_to?(:provides)

require 'chef/mixin/shell_out'
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('repository provider, repository load current resource')
  @current_resource ||= Chef::Resource::FmwRcuRepository.new(new_resource.name)
  @current_resource.java_home_dir(@new_resource.java_home_dir)
  @current_resource.oracle_home_dir(@new_resource.oracle_home_dir)
  @current_resource.middleware_home_dir(@new_resource.middleware_home_dir)
  @current_resource.version(@new_resource.version)
  @current_resource.db_connect_url(@new_resource.db_connect_url)
  @current_resource.jdbc_connect_url(@new_resource.jdbc_connect_url)
  @current_resource.db_connect_user(@new_resource.db_connect_user)
  @current_resource.db_connect_password(@new_resource.db_connect_password)
  @current_resource.rcu_prefix(@new_resource.rcu_prefix)
  @current_resource.rcu_components(@new_resource.rcu_components)
  @current_resource.rcu_component_password(@new_resource.rcu_component_password)
  @current_resource.os_user(@new_resource.os_user)
  @current_resource.os_group(@new_resource.os_group)
  @current_resource.tmp_dir(@new_resource.tmp_dir)

  if @new_resource.version == '10.3.6'
    wlst_utility = "#{@new_resource.middleware_home_dir}/wlserver_10.3/common/bin/wlst.sh"
  else
    wlst_utility = "#{@new_resource.middleware_home_dir}/oracle_common/common/bin/wlst.sh"
  end

  shell_out!("su - #{@new_resource.os_user} -c '#{wlst_utility} #{@new_resource.tmp_dir}/checkrcu.py #{@new_resource.jdbc_connect_url} #{@new_resource.db_connect_password} #{@new_resource.rcu_prefix} #{@new_resource.db_connect_user}'").stdout.each_line do |line|
    unless line.nil?
      if line.include? 'found'
        @current_resource.exists = true
      end
      fail if line.include? 'IO Error'
    end
  end

  @current_resource
end

# add a FMW repository on an Oracle database
action :create do
  Chef::Log.info("#{@new_resource} fired the extract action")
  if @current_resource.exists
    Chef::Log.info("#{@new_resource} already extracted")
  else
    converge_by("Create resource #{ @new_resource }") do

      components_string = ' -component ' + @new_resource.rcu_components.join(' -component ')

      script = 'rcu_input'
      content = "#{new_resource.db_connect_password}\n"
      for i in 0..new_resource.rcu_components.length
        content += "#{new_resource.rcu_component_password}\n"
      end

      tmp_file = Tempfile.new([script, '.py'])
      tmp_file.write(content)
      tmp_file.close
      FileUtils.chown(new_resource.os_user, new_resource.os_group, tmp_file.path)

      execute "Create #{new_resource.rcu_prefix}" do
        command "#{new_resource.oracle_home_dir}/bin/rcu -silent -createRepository -databaseType ORACLE -connectString #{new_resource.db_connect_url} -dbUser #{new_resource.db_connect_user} -dbRole SYSDBA  -schemaPrefix #{new_resource.rcu_prefix} #{components_string} -f < #{tmp_file.path}"
        user new_resource.os_user
        group new_resource.os_group
        cwd new_resource.tmp_dir
        environment('JAVA_HOME' => new_resource.java_home_dir)
      end

      new_resource.updated_by_last_action(true)
    end
  end
end

# drop a FMW repository on an Oracle database
action :drop do
  Chef::Log.info("#{@new_resource} fired the extract action")
  if @current_resource.exists
    converge_by("Delete resource #{ @new_resource }") do

      components_string = ' -component ' + @new_resource.rcu_components.join(' -component ')

      script = 'rcu_input'
      content = "#{new_resource.db_connect_password}\n"
      for i in 0..new_resource.rcu_components.length
        content += "#{new_resource.rcu_component_password}\n"
      end

      tmp_file = Tempfile.new([script, '.py'])
      tmp_file.write(content)
      tmp_file.close
      FileUtils.chown(new_resource.os_user, new_resource.os_group, tmp_file.path)

      execute "Create #{new_resource.rcu_prefix}" do
        command "#{new_resource.oracle_home_dir}/bin/rcu -silent -dropRepository -databaseType ORACLE -connectString #{new_resource.db_connect_url} -dbUser #{new_resource.db_connect_user} -dbRole SYSDBA  -schemaPrefix #{new_resource.rcu_prefix} #{components_string} -f < #{tmp_file.path}"
        user new_resource.os_user
        group new_resource.os_group
        cwd new_resource.tmp_dir
        environment('JAVA_HOME' => new_resource.java_home_dir)
      end

      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.info("#{@new_resource} already deleted")
  end
end
