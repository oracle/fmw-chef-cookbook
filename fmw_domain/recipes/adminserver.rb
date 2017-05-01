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
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
