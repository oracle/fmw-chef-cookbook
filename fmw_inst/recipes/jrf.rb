#
# Cookbook Name:: fmw_inst
# Recipe:: jrf
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

include_recipe 'fmw_wls::install'

fail 'fmw_inst attributes cannot be empty' unless node.attribute?('fmw_inst')

if ['12.2.1', '12.2.1.1', '12.2.1.2', '12.1.3', '12.1.2'].include?(node['fmw']['version'])
  return

elsif ['10.3.6'].include?(node['fmw']['version'])

  fmw_template = 'fmw_11g.rsp'
  fmw_oracle_home = node['fmw']['middleware_home_dir'] + '/oracle_common'
  install_type = ''
  option_array = []

  if node['os'].include?('windows')
    fmw_installer_file = node['fmw']['tmp_dir'] + '/jrf/Disk1/setup.exe'
  else
    fmw_installer_file = node['fmw']['tmp_dir'] + '/jrf/Disk1/runInstaller'
  end

end

if node['os'].include?('windows')
  unix = false
else
  unix = true
end

template node['fmw']['tmp_dir'] + '/jrf_' + fmw_template do
  source fmw_template
  mode 0755                                                          if unix
  owner node['fmw']['os_user']                                       if unix
  group node['fmw']['os_group']                                      if unix
  variables(middleware_home_dir: node['fmw']['middleware_home_dir'],
            oracle_home: fmw_oracle_home,
            install_type: install_type,
            option_array: option_array)
end

fmw_inst_fmw_extract 'jrf' do
  action              :extract
  source_file         node['fmw_inst']['jrf_source_file']
  os_user             node['fmw']['os_user']                       if unix
  os_group            node['fmw']['os_group']                      if unix
  tmp_dir             node['fmw']['tmp_dir']
  version             node['fmw']['version']                       unless unix
  middleware_home_dir node['fmw']['middleware_home_dir']           unless unix
end

fmw_inst_fmw_install 'jrf' do
  action              :install
  java_home_dir       node['fmw']['java_home_dir']
  installer_file      fmw_installer_file
  rsp_file            node['fmw']['tmp_dir'] + '/jrf_' + fmw_template
  version             node['fmw']['version']
  oracle_home_dir     fmw_oracle_home
  orainst_dir         node['fmw']['orainst_dir']                    if unix
  os_user             node['fmw']['os_user']                        if unix
  os_group            node['fmw']['os_group']                       if unix
  tmp_dir             node['fmw']['tmp_dir']
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
