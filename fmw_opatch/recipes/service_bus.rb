#
# Cookbook Name:: fmw_opatch
# Recipe:: service_bus
#
# Copyright 2015 Oracle. All Rights Reserved
#
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

include_recipe 'fmw_inst::service_bus'

fail 'fmw_opatch attributes cannot be empty' unless node.attribute?('fmw_opatch')
fail 'source_file parameter cannot be empty' unless node['fmw_opatch'].attribute?('service_bus_source_file')
fail 'patch_id parameter cannot be empty' unless node['fmw_opatch'].attribute?('service_bus_patch_id')

if ['12.2.1', '12.2.1.1', '12.2.1.2', '12.2.1.3', '12.1.3'].include?(node['fmw']['version'])
  fmw_oracle_home = node['fmw']['middleware_home_dir']
elsif ['10.3.6'].include?(node['fmw']['version'])
  if node['os'].include?('windows')
    fmw_oracle_home = node['fmw']['middleware_home_dir'] + '\\Oracle_OSB1'
  else
    fmw_oracle_home = node['fmw']['middleware_home_dir'] + '/Oracle_OSB1'
  end
end

fmw_opatch_fmw_extract node['fmw_opatch']['service_bus_patch_id'] do
  action              :extract
  source_file         node['fmw_opatch']['service_bus_source_file']
  os_user             node['fmw']['os_user']             if ['solaris2', 'linux'].include?(node['os'])
  os_group            node['fmw']['os_group']            if ['solaris2', 'linux'].include?(node['os'])
  tmp_dir             node['fmw']['tmp_dir']
  middleware_home_dir node['fmw']['middleware_home_dir'] if node['os'].include?('windows')
  version             node['fmw']['version']             if node['os'].include?('windows')
end

fmw_opatch_opatch node['fmw_opatch']['service_bus_patch_id'] do
  action              :apply
  patch_id            node['fmw_opatch']['service_bus_patch_id']
  oracle_home_dir     fmw_oracle_home
  java_home_dir       node['fmw']['java_home_dir']
  orainst_dir         node['fmw']['orainst_dir']         if ['solaris2', 'linux'].include?(node['os'])
  os_user             node['fmw']['os_user']             if ['solaris2', 'linux'].include?(node['os'])
  os_group            node['fmw']['os_group']            if ['solaris2', 'linux'].include?(node['os'])
  tmp_dir             node['fmw']['tmp_dir']
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
