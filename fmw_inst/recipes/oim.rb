#
# Cookbook Name:: fmw_inst
# Recipe:: oim
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

include_recipe 'fmw_wls::install'

fail 'fmw_inst attributes cannot be empty' unless node.attribute?('fmw_inst')

if node['os'].include?('windows')
  unix = false
else
  unix = true
end

puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: checking oim version"
if ['11.1.2'].include?(node['fmw_inst']['oim_version'])
  fmw_template = 'fmw_12c.rsp'
  fmw_oracle_home = node['fmw']['middleware_home_dir'] + '/oim/bin'
  install_type = 'Typical'
  option_array = []
  if node['os'].include?('windows')
    fmw_installer_file = node['fmw']['tmp_dir'] + '/oim/Disk1/setup.exe'
  else
    fmw_installer_file = node['fmw']['tmp_dir'] + '/oim/Disk1/runInstaller'
  end

  template node['fmw']['tmp_dir'] + '/oim_' + fmw_template do
    source fmw_template
    mode 0755                                                          if unix
    owner node['fmw']['os_user']                                       if unix
    group node['fmw']['os_group']                                      if unix
    variables(middleware_home_dir: node['fmw']['middleware_home_dir'],
      oracle_home: fmw_oracle_home,
      install_type: install_type,
      option_array: option_array)
  end

  fmw_inst_fmw_extract 'oim' do
    action              :extract
    source_file         node['fmw_inst']['oim_source_file_1']
    source_2_file       node['fmw_inst']['oim_source_file_2']
    source_3_file       node['fmw_inst']['oim_source_file_3']
    os_user             node['fmw']['os_user']                        if unix
    os_group            node['fmw']['os_group']                       if unix
    tmp_dir             node['fmw']['tmp_dir']
    version             node['fmw_inst']['oim_version']               unless unix
    middleware_home_dir node['fmw']['middleware_home_dir']            unless unix
  end

  fmw_inst_fmw_install 'oim' do
    action              :install
    java_home_dir       node['fmw']['java_home_dir']
    installer_file      fmw_installer_file
    rsp_file            node['fmw']['tmp_dir'] + '/oim_' + fmw_template
    version             node['fmw_inst']['oim_version']
    oracle_home_dir     fmw_oracle_home
    orainst_dir         node['fmw']['orainst_dir']                   if unix
    os_user             node['fmw']['os_user']                       if unix
    os_group            node['fmw']['os_group']                      if unix
    tmp_dir             node['fmw']['tmp_dir']
  end

end
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
