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

if VERSION.start_with? '11.'
  ruby_block "loading for chef 11 wls install" do
    block do
      if node['os'].include?('linux')
        res = Chef::Resource::Chef::Resource::FmwWlsWlsLinux.new( node['fmw']['middleware_home_dir'], run_context )
      elsif node['os'].include?('solaris2')
        res = Chef::Resource::Chef::Resource::FmwWlsWlsSolaris.new( node['fmw']['middleware_home_dir'], run_context )
      else
        res = Chef::Resource::Chef::Resource::FmwWlsWlsWindows.new( node['fmw']['middleware_home_dir'], run_context )
      end
      res.java_home_dir       node['fmw']['java_home_dir']
      res.source_file         node['fmw_wls']['source_file']
      res.version             node['fmw']['version']
      res.install_type        node['fmw_wls']['install_type']
      res.middleware_home_dir node['fmw']['middleware_home_dir']
      res.ora_inventory_dir   node['fmw']['ora_inventory_dir']
      res.orainst_dir         node['fmw']['orainst_dir']          if unix
      res.os_user             node['fmw']['os_user']              if unix
      res.os_group            node['fmw']['os_group']             if unix
      res.tmp_dir             node['fmw']['tmp_dir']
      res.run_action          :install
    end
  end
else
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
end




# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
