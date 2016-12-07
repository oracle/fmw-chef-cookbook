#
# Cookbook Name:: fmw_inst
# Recipe:: mft
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

include_recipe 'fmw_wls::install'

fail 'fmw_inst attributes cannot be empty' unless node.attribute?('fmw_inst')

if ['12.2.1', '12.2.1.1', '12.2.1.2', '12.1.3'].include?(node['fmw']['version'])
  fmw_template = 'fmw_12c.rsp'
  fmw_oracle_home = node['fmw']['middleware_home_dir'] + '/mft/bin'
  install_type = 'Typical'
  option_array = []

  if node['fmw']['version'] == '12.1.3'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/mft/fmw_12.1.3.0.0_mft.jar'
  elsif node['fmw']['version'] == '12.2.1'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/mft/fmw_12.2.1.0.0_mft.jar'
  elsif node['fmw']['version'] == '12.2.1.1'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/mft/fmw_12.2.1.1.0_mft.jar'
  elsif node['fmw']['version'] == '12.2.1.2'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/mft/fmw_12.2.1.2.0_mft.jar'
  end

elsif ['10.3.6'].include?(node['fmw']['version'])
  return
end

if node['os'].include?('windows')
  unix = false
else
  unix = true
end

template node['fmw']['tmp_dir'] + '/mft_' + fmw_template do
  source fmw_template
  mode 0755                                                          if unix
  owner node['fmw']['os_user']                                       if unix
  group node['fmw']['os_group']                                      if unix
  variables(middleware_home_dir: node['fmw']['middleware_home_dir'],
            oracle_home: fmw_oracle_home,
            install_type: install_type,
            option_array: option_array)
end

# chef version 11
if VERSION.start_with? '11.'
  if ['12.1.3', '12.2.1', '12.2.1.1', '12.2.1.2'].include?(node['fmw']['version'])
    ruby_block "loading for chef 11 install mft extract" do
      block do
        if node['os'].include?('windows')
          res = Chef::Resource::Chef::Resource::FmwInstFmwExtractWindows.new('mft', run_context )
        else
          res = Chef::Resource::Chef::Resource::FmwInstFmwExtract.new('mft', run_context )
        end
        res.source_file         node['fmw_inst']['mft_source_file']
        res.os_user             node['fmw']['os_user']                      if unix
        res.os_group            node['fmw']['os_group']                     if unix
        res.tmp_dir             node['fmw']['tmp_dir']
        res.version             node['fmw']['version']                      unless unix
        res.middleware_home_dir node['fmw']['middleware_home_dir']          unless unix
        res.run_action          :extract
      end
    end
  end
  ruby_block "loading for chef 11 install mft" do
    block do
      if node['os'].include?('windows')
        res2 = Chef::Resource::Chef::Resource::FmwInstFmwInstallWindows.new('mft', run_context )
      elsif node['os'].include?('solaris2')
        res2 = Chef::Resource::Chef::Resource::FmwInstFmwInstallSolaris.new('mft', run_context )
      else
        res2 = Chef::Resource::Chef::Resource::FmwInstFmwInstallLinux.new('mft', run_context )
      end
      res2.java_home_dir       node['fmw']['java_home_dir']
      res2.installer_file      fmw_installer_file
      res2.rsp_file            node['fmw']['tmp_dir'] + '/mft_' + fmw_template
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
  if ['12.1.3', '12.2.1', '12.2.1.1', '12.2.1.2'].include?(node['fmw']['version'])
    fmw_inst_fmw_extract 'mft' do
      action              :extract
      source_file         node['fmw_inst']['mft_source_file']
      os_user             node['fmw']['os_user']                      if unix
      os_group            node['fmw']['os_group']                     if unix
      tmp_dir             node['fmw']['tmp_dir']
      version             node['fmw']['version']                      unless unix
      middleware_home_dir node['fmw']['middleware_home_dir']          unless unix
    end
  end

  fmw_inst_fmw_install 'mft' do
    action              :install
    java_home_dir       node['fmw']['java_home_dir']
    installer_file      fmw_installer_file
    rsp_file            node['fmw']['tmp_dir'] + '/mft_' + fmw_template
    version             node['fmw']['version']
    oracle_home_dir     fmw_oracle_home
    orainst_dir         node['fmw']['orainst_dir']                   if unix
    os_user             node['fmw']['os_user']                       if unix
    os_group            node['fmw']['os_group']                      if unix
    tmp_dir             node['fmw']['tmp_dir']
  end
end
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
