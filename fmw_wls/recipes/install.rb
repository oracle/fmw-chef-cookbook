#
# Cookbook Name:: fmw_wls
# Recipe:: install
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

include_recipe 'fmw_jdk::install'

if node['os'].include?('windows')
  unix = false
else
  unix = true
end

fmw_wls_wls node['fmw']['middleware_home_dir'] do
  action              :install
  java_home_dir       node['fmw']['java_home_dir']
  source_file         node['fmw_wls']['source_file']
  version             node['fmw']['version']
  install_type        node['fmw_wls']['install_type']
  middleware_home_dir node['fmw']['middleware_home_dir']
  ora_inventory_dir   node['fmw']['ora_inventory_dir']
  orainst_dir         node['fmw']['orainst_dir']          if unix
  os_user             node['fmw']['os_user']              if unix
  os_group            node['fmw']['os_group']             if unix
  tmp_dir             node['fmw']['tmp_dir']
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
