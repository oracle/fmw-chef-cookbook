#
# Cookbook Name:: fmw_inst
# Recipe:: soa_suite
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

include_recipe 'fmw_wls::install'

fail 'fmw_inst attributes cannot be empty' unless node.attribute?('fmw_inst')

if ['12.2.1', '12.2.1.1', '12.1.3'].include?(node['fmw']['version'])
  fmw_template = 'fmw_12c.rsp'
  fmw_oracle_home = node['fmw']['middleware_home_dir'] + '/soa/bin'
  option_array = []

  if node.attribute?('fmw_inst')
    if node['fmw_inst'].attribute?('soa_suite_install_type')
      unless ['BPM', 'SOA Suite'].include?(node['fmw_inst']['soa_suite_install_type'])
        fail 'unknown soa_suite_install_type please use BPM|SOA Suite'
      end
      install_type = node['fmw_inst']['soa_suite_install_type']
    else
      install_type = 'SOA Suite'
    end
  else
    install_type = 'SOA Suite'
  end

  if node['fmw']['version'] == '12.1.3'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/soa_suite/fmw_12.1.3.0.0_soa.jar'
  elsif node['fmw']['version'] == '12.2.1'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/soa_suite/fmw_12.2.1.0.0_soa.jar'
  elsif node['fmw']['version'] == '12.2.1.1'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/soa_suite/fmw_12.2.1.1.0_soa.jar'
  end

elsif ['10.3.6'].include?(node['fmw']['version'])
  fmw_template = 'fmw_11g.rsp'
  fmw_oracle_home = node['fmw']['middleware_home_dir'] + '/Oracle_SOA1'
  install_type = ''
  option_array = ['APPSERVER_TYPE=WLS',
                  "APPSERVER_LOCATION=#{node['fmw']['middleware_home_dir']}"]

  if node['os'].include?('windows')
    fmw_installer_file = node['fmw']['tmp_dir'] + '/soa_suite/Disk1/setup.exe'
  else
    fmw_installer_file = node['fmw']['tmp_dir'] + '/soa_suite/Disk1/runInstaller'
  end
end

if node['os'].include?('windows')
  unix = false
else
  unix = true
end

template node['fmw']['tmp_dir'] + '/soa_' + fmw_template do
  source fmw_template
  mode 0755                                                         if unix
  owner node['fmw']['os_user']                                      if unix
  group node['fmw']['os_group']                                     if unix
  variables(middleware_home_dir: node['fmw']['middleware_home_dir'],
            oracle_home: fmw_oracle_home,
            install_type: install_type,
            option_array: option_array)
end

# chef version 11
if VERSION.start_with? '11.'
  if ['10.3.6', '12.1.3', '12.2.1', '12.2.1.1'].include?(node['fmw']['version'])
    ruby_block "loading for chef 11 install soa_suite extract" do
      block do
        if node['os'].include?('windows')
          res = Chef::Resource::Chef::Resource::FmwInstFmwExtractWindows.new('soa_suite', run_context )
        else
          res = Chef::Resource::Chef::Resource::FmwInstFmwExtract.new('soa_suite', run_context )
        end
        res.source_file         node['fmw_inst']['soa_suite_source_file']
        res.source_2_file       node['fmw_inst']['soa_suite_source_2_file'] if node['fmw_inst'].attribute?('soa_suite_source_2_file')
        res.os_user             node['fmw']['os_user']                      if unix
        res.os_group            node['fmw']['os_group']                     if unix
        res.tmp_dir             node['fmw']['tmp_dir']
        res.version             node['fmw']['version']                      unless unix
        res.middleware_home_dir node['fmw']['middleware_home_dir']          unless unix
        res.run_action          :extract
      end
    end
  end
  ruby_block "loading for chef 11 install soa_suite" do
    block do
      if node['os'].include?('windows')
        res2 = Chef::Resource::Chef::Resource::FmwInstFmwInstallWindows.new('soa_suite', run_context )
      elsif node['os'].include?('solaris2')
        res2 = Chef::Resource::Chef::Resource::FmwInstFmwInstallSolaris.new('soa_suite', run_context )
      else
        res2 = Chef::Resource::Chef::Resource::FmwInstFmwInstallLinux.new('soa_suite', run_context )
      end
      res2.java_home_dir       node['fmw']['java_home_dir']
      res2.installer_file      fmw_installer_file
      res2.rsp_file            node['fmw']['tmp_dir'] + '/soa_' + fmw_template
      res2.version             node['fmw']['version']
      res2.oracle_home_dir     fmw_oracle_home
      res2.orainst_dir         node['fmw']['orainst_dir']                      if unix
      res2.os_user             node['fmw']['os_user']                          if unix
      res2.os_group            node['fmw']['os_group']                         if unix
      res2.tmp_dir             node['fmw']['tmp_dir']
      res2.run_action          :install
    end
  end
else
  if ['10.3.6', '12.1.3', '12.2.1', '12.2.1.1'].include?(node['fmw']['version'])
    fmw_inst_fmw_extract 'soa_suite' do
      action              :extract
      source_file         node['fmw_inst']['soa_suite_source_file']
      source_2_file       node['fmw_inst']['soa_suite_source_2_file'] if node['fmw_inst'].attribute?('soa_suite_source_2_file')
      os_user             node['fmw']['os_user']                      if unix
      os_group            node['fmw']['os_group']                     if unix
      tmp_dir             node['fmw']['tmp_dir']
      version             node['fmw']['version']                      unless unix
      middleware_home_dir node['fmw']['middleware_home_dir']          unless unix
    end
  end

  fmw_inst_fmw_install 'soa_suite' do
    action              :install
    java_home_dir       node['fmw']['java_home_dir']
    installer_file      fmw_installer_file
    rsp_file            node['fmw']['tmp_dir'] + '/soa_' + fmw_template
    version             node['fmw']['version']
    oracle_home_dir     fmw_oracle_home
    orainst_dir         node['fmw']['orainst_dir']                      if unix
    os_user             node['fmw']['os_user']                          if unix
    os_group            node['fmw']['os_group']                         if unix
    tmp_dir             node['fmw']['tmp_dir']
  end
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
