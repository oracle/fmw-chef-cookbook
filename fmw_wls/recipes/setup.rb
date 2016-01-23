#
# Cookbook Name:: fmw_wls
# Recipe:: setup
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

if platform_family?('windows')
  return
end

group node['fmw']['os_group'] do
  action :create
end

user node['fmw']['os_user'] do
  comment 'created by chef for WebLogic installation'
  gid node['fmw']['os_group']
  shell node['fmw']['os_shell']
  home node['fmw']['user_home_dir'] + '/' + node['fmw']['os_user']
  manage_home true
  action :create
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
