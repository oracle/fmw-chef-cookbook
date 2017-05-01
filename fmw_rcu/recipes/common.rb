#
# Cookbook Name:: fmw_rcu
# Recipe:: common
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

fail 'fmw_rcu attributes cannot be empty' unless node.attribute?('fmw_rcu')
fail 'databag_key parameter cannot be empty' unless node['fmw_rcu'].attribute?('databag_key')

rcu_params =  begin
                data_bag_item('fmw_databases',node['fmw_rcu']['databag_key'])
              rescue Net::HTTPServerException, Chef::Exceptions::ValidationFailed, Chef::Exceptions::InvalidDataBagPath
                [] # empty array for length comparison
              end

rcu_params = rcu_params.to_hash if rcu_params.instance_of? Chef::EncryptedDataBagItem
fail 'did not find the data_bag_item' if rcu_params.length == 0

include_recipe 'fmw_wls::install'

if ['12.2.1', '12.2.1.1', '12.2.1.2', '12.1.3'].include?(node['fmw']['version'])
  fail 'oracle_home_dir parameter cannot be empty' unless node['fmw_rcu'].attribute?('oracle_home_dir')
  oracle_home_dir   = node['fmw_rcu']['oracle_home_dir']
end

if ['12.2.1', '12.2.1.1', '12.2.1.2'].include?(node['fmw']['version'])

  component_array = ['MDS',
                     'IAU',
                     'IAU_APPEND',
                     'IAU_VIEWER',
                     'OPSS',
                     'WLS',
                     'STB',
                     'UCSUMS']

elsif ['12.1.3'].include?(node['fmw']['version'])

  component_array = ['MDS',
                     'IAU',
                     'IAU_APPEND',
                     'IAU_VIEWER',
                     'OPSS',
                     'WLS',
                     'UCSUMS']

elsif ['10.3.6'].include?(node['fmw']['version'])

  fail 'source_file parameter cannot be empty' unless node['fmw_rcu'].attribute?('source_file')
  fail 'there is no rcu installer supported for solaris' if node['os'].include?('solaris2')

  component_array = ['MDS',
                     'OPSS',
                     'ORASDPM']

  if platform_family?('windows')

    path = "#{node['fmw']['middleware_home_dir']}\\wlserver_10.3\\server\\adr"

    execute "extract rcu file" do
      command "#{path}\\unzip.exe  -o #{node['fmw_rcu']['source_file']} -d #{node['fmw']['tmp_dir']}\\rcu"
      cwd node['fmw']['tmp_dir']
      creates "#{node['fmw']['tmp_dir']}\\rcu\\rcuHome"
    end
    oracle_home_dir   = "#{node['fmw']['tmp_dir']}\\rcu\\rcuHome"
  else
    execute "extract rcu file" do
      command "unzip -o #{node['fmw_rcu']['source_file']} -d #{node['fmw']['tmp_dir']}/rcu"
      cwd node['fmw']['tmp_dir']
      user node['fmw']['os_user']
      group node['fmw']['os_group']
      creates "#{node['fmw']['tmp_dir']}/rcu/rcuHome"
    end
    oracle_home_dir   = "#{node['fmw']['tmp_dir']}/rcu/rcuHome"
  end

end

if platform_family?('windows')

  cookbook_file "#{node['fmw']['tmp_dir']}/checkrcu.py" do
    source 'checkrcu.py'
    action :create
  end

  fmw_rcu_repository node['fmw_rcu']['rcu_prefix'] do
    action                 :create
    java_home_dir          node['fmw']['java_home_dir']
    oracle_home_dir        oracle_home_dir
    middleware_home_dir    node['fmw']['middleware_home_dir']
    version                node['fmw']['version']
    jdbc_connect_url       node['fmw_rcu']['jdbc_database_url']
    db_connect_url         node['fmw_rcu']['db_database_url']
    db_connect_user        node['fmw_rcu']['db_sys_user']
    db_connect_password    rcu_params['db_sys_password']
    rcu_prefix             node['fmw_rcu']['rcu_prefix']
    rcu_components         component_array
    rcu_component_password rcu_params['rcu_component_password']
    tmp_dir                node['fmw']['tmp_dir']
  end

else

  cookbook_file "#{node['fmw']['tmp_dir']}/checkrcu.py" do
    source 'checkrcu.py'
    action :create
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
    mode 0775
  end

  fmw_rcu_repository node['fmw_rcu']['rcu_prefix'] do
    action                 :create
    java_home_dir          node['fmw']['java_home_dir']
    oracle_home_dir        oracle_home_dir
    middleware_home_dir    node['fmw']['middleware_home_dir']
    version                node['fmw']['version']
    jdbc_connect_url       node['fmw_rcu']['jdbc_database_url']
    db_connect_url         node['fmw_rcu']['db_database_url']
    db_connect_user        node['fmw_rcu']['db_sys_user']
    db_connect_password    rcu_params['db_sys_password']
    rcu_prefix             node['fmw_rcu']['rcu_prefix']
    rcu_components         component_array
    rcu_component_password rcu_params['rcu_component_password']
    os_user                node['fmw']['os_user']
    os_group               node['fmw']['os_group']
    tmp_dir                node['fmw']['tmp_dir']
  end

end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
