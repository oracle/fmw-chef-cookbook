#
# Cookbook Name:: fmw_inst
# Recipe:: service_bus
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

include_recipe 'fmw_wls::install'

fail 'fmw_inst attributes cannot be empty' unless node.attribute?('fmw_inst')

if ['12.2.1', '12.2.1.1', '12.2.1.2', '12.1.3'].include?(node['fmw']['version'])
  fmw_template = 'fmw_12c.rsp'
  fmw_oracle_home = node['fmw']['middleware_home_dir'] + '/osb/bin'
  install_type = 'Service Bus'
  option_array = []

  if node['fmw']['version'] == '12.1.3'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/service_bus/fmw_12.1.3.0.0_osb.jar'
  elsif node['fmw']['version'] == '12.2.1'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/service_bus/fmw_12.2.1.0.0_osb.jar'
  elsif node['fmw']['version'] == '12.2.1.1'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/service_bus/fmw_12.2.1.1.0_osb.jar'
  elsif node['fmw']['version'] == '12.2.1.2'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/service_bus/fmw_12.2.1.2.0_osb.jar'
  end

elsif ['10.3.6'].include?(node['fmw']['version'])
  fmw_template = 'fmw_11g.rsp'
  fmw_oracle_home = node['fmw']['middleware_home_dir'] + '/Oracle_OSB1'
  install_type = ''
  option_array = ['TYPICAL TYPE=false',
                  'CUSTOM TYPE=true',
                  'Oracle Service Bus Examples=false',
                  'Oracle Service Bus IDE=false',
                  "WL_HOME=#{node['fmw']['middleware_home_dir']}/wlserver_10.3"]

  if node['os'].include?('windows')
    fmw_installer_file = node['fmw']['tmp_dir'] + '/service_bus/Disk1/setup.exe'
  else
    fmw_installer_file = node['fmw']['tmp_dir'] + '/service_bus/Disk1/runInstaller'
  end
end

if node['os'].include?('windows')
  unix = false
else
  unix = true
end

template node['fmw']['tmp_dir'] + '/sb_' + fmw_template do
  source fmw_template
  mode 0755                                                           if unix
  owner node['fmw']['os_user']                                        if unix
  group node['fmw']['os_group']                                       if unix
  variables(middleware_home_dir: node['fmw']['middleware_home_dir'],
            oracle_home: fmw_oracle_home,
            install_type: install_type,
            option_array: option_array)
end

if ['10.3.6', '12.1.3', '12.2.1', '12.2.1.1', '12.2.1.2'].include?(node['fmw']['version'])
  fmw_inst_fmw_extract 'service_bus' do
    action              :extract
    source_file         node['fmw_inst']['service_bus_source_file']
    os_user             node['fmw']['os_user']                       if unix
    os_group            node['fmw']['os_group']                      if unix
    tmp_dir             node['fmw']['tmp_dir']
    version             node['fmw']['version']                       unless unix
    middleware_home_dir node['fmw']['middleware_home_dir']           unless unix
  end
end

fmw_inst_fmw_install 'service_bus' do
  action              :install
  java_home_dir       node['fmw']['java_home_dir']
  installer_file      fmw_installer_file
  rsp_file            node['fmw']['tmp_dir'] + '/sb_' + fmw_template
  version             node['fmw']['version']
  oracle_home_dir     fmw_oracle_home
  orainst_dir         node['fmw']['orainst_dir']                    if unix
  os_user             node['fmw']['os_user']                        if unix
  os_group            node['fmw']['os_group']                       if unix
  tmp_dir             node['fmw']['tmp_dir']
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
