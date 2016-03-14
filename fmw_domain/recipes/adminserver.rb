#
# Cookbook Name:: fmw_domain
# Recipe:: adminserver
#
# Copyright 2015 Oracle. All Rights Reserved
#
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

fail 'databag_key parameter cannot be empty' unless node['fmw_domain'].attribute?('databag_key')

include_recipe 'fmw_domain::nodemanager'

domain_params =  begin
                data_bag_item('fmw_domains',node['fmw_domain']['databag_key'])
              rescue Net::HTTPServerException, Chef::Exceptions::ValidationFailed, Chef::Exceptions::InvalidDataBagPath
                [] # empty array for length comparison
              end
domain_params = domain_params.to_hash if domain_params.instance_of? Chef::EncryptedDataBagItem


if node['os'].include?('windows')

  if VERSION.start_with? '11.'
    ruby_block "loading for chef 11 adminserver" do
      block do
        res = Chef::Resource::Chef::Resource::FmwDomainAdminserverWindows.new('adminserver', run_context )
        res.domain_dir                 "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}"
        res.domain_name                domain_params['domain_name']
        res.adminserver_name           domain_params['adminserver_name']
        res.weblogic_home_dir          node['fmw']['weblogic_home_dir']
        res.java_home_dir              node['fmw']['java_home_dir']
        res.weblogic_user              domain_params['weblogic_user']
        res.weblogic_password          domain_params['weblogic_password']
        res.nodemanager_listen_address node['fmw_domain']['nodemanager_listen_address']
        res.nodemanager_port           node['fmw_domain']['nodemanager_port']
        res.run_action                 :start
      end
    end
  else
    fmw_domain_adminserver 'adminserver' do
      action                     :start
      domain_dir                 "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}"
      domain_name                domain_params['domain_name']
      adminserver_name           domain_params['adminserver_name']
      weblogic_home_dir          node['fmw']['weblogic_home_dir']
      java_home_dir              node['fmw']['java_home_dir']
      weblogic_user              domain_params['weblogic_user']
      weblogic_password          domain_params['weblogic_password']
      nodemanager_listen_address node['fmw_domain']['nodemanager_listen_address']
      nodemanager_port           node['fmw_domain']['nodemanager_port']
    end
  end
else
  if VERSION.start_with? '11.'
    ruby_block "loading for chef 11 adminserver" do
      block do
        res = Chef::Resource::Chef::Resource::FmwDomainAdminserverLinux.new('adminserver', run_context )   if node['os'].include?('linux')
        res = Chef::Resource::Chef::Resource::FmwDomainAdminserverSolaris.new('adminserver', run_context ) if node['os'].include?('solaris2')
        res.domain_dir                 "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}"
        res.domain_name                domain_params['domain_name']
        res.adminserver_name           domain_params['adminserver_name']
        res.weblogic_home_dir          node['fmw']['weblogic_home_dir']
        res.java_home_dir              node['fmw']['java_home_dir']
        res.weblogic_user              domain_params['weblogic_user']
        res.weblogic_password          domain_params['weblogic_password']
        res.nodemanager_listen_address node['fmw_domain']['nodemanager_listen_address']
        res.nodemanager_port           node['fmw_domain']['nodemanager_port']
        res.os_user                    node['fmw']['os_user']
        res.run_action                 :start
      end
    end
  else
    fmw_domain_adminserver 'adminserver' do
      action                     :start
      domain_dir                 "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}"
      domain_name                domain_params['domain_name']
      adminserver_name           domain_params['adminserver_name']
      weblogic_home_dir          node['fmw']['weblogic_home_dir']
      os_user                    node['fmw']['os_user']
      java_home_dir              node['fmw']['java_home_dir']
      weblogic_user              domain_params['weblogic_user']
      weblogic_password          domain_params['weblogic_password']
      nodemanager_listen_address node['fmw_domain']['nodemanager_listen_address']
      nodemanager_port           node['fmw_domain']['nodemanager_port']
    end
  end
end
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
