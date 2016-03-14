#
# Cookbook Name:: fmw_domain
# Recipe:: domain
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

fail 'weblogic_home_dir parameter cannot be empty' unless node['fmw'].attribute?('weblogic_home_dir')
fail 'databag_key parameter cannot be empty' unless node['fmw_domain'].attribute?('databag_key')

include_recipe 'fmw_wls::install'

domain_params =  begin
                data_bag_item('fmw_domains',node['fmw_domain']['databag_key'])
              rescue Net::HTTPServerException, Chef::Exceptions::ValidationFailed, Chef::Exceptions::InvalidDataBagPath
                [] # empty array for length comparison
              end
domain_params = domain_params.to_hash if domain_params.instance_of? Chef::EncryptedDataBagItem

if node['fmw_domain'].attribute?('nodemanagers')
  # validate
  nodemanagers = node['fmw_domain']['nodemanagers']
else
  nodemanagers = []
end

if node['fmw_domain'].attribute?('servers')
  # validate
  servers = node['fmw_domain']['servers']
else
  servers = []
end

if node['fmw_domain'].attribute?('clusters')
  # validate
  clusters = node['fmw_domain']['clusters']
else
  clusters = []
end

fail 'did not find the data_bag_item' if domain_params.length == 0

if ['12.2.1', '12.1.3', '12.1.2'].include?(node['fmw']['version'])
  wls_base_template = "#{node['fmw']['weblogic_home_dir']}/common/templates/wls/wls.jar"
elsif ['10.3.6', '12.1.1'].include?(node['fmw']['version'])
  wls_base_template = "#{node['fmw']['weblogic_home_dir']}/common/templates/domains/wls.jar"
end

if node['os'].include?('windows')
  # add the common utils py script to the tmp dir
  cookbook_file node['fmw']['tmp_dir'] + '/common.py' do
    source 'domain/common.py'
    action :create
  end

  # add the domain py script to the tmp dir
  template node['fmw']['tmp_dir'] + '/domain.py' do
    source 'domain/domain.py'
    variables(weblogic_home_dir:             node['fmw']['weblogic_home_dir'],
              java_home_dir:                 node['fmw']['java_home_dir'],
              wls_base_template:             wls_base_template,
              domain_dir:                    "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}",
              domain_name:                   domain_params['domain_name'],
              weblogic_user:                 domain_params['weblogic_user'],
              adminserver_name:              domain_params['adminserver_name'],
              adminserver_startup_arguments: node['fmw_domain']['adminserver_startup_arguments'],
              adminserver_listen_address:    domain_params['adminserver_listen_address'],
              adminserver_listen_port:       domain_params['adminserver_listen_port'],
              nodemanager_port:              node['fmw_domain']['nodemanager_port'],
              nodemanagers:                  nodemanagers,
              servers:                       servers,
              clusters:                      clusters,
              tmp_dir:                       node['fmw']['tmp_dir'].gsub('\\\\', '/').gsub('\\', '/')
              )
  end

  # make sure the domains directory exists
  directory node['fmw_domain']['domains_dir'] do
    recursive true
    action :create
  end

  # create domain
  if VERSION.start_with? '11.'
    ruby_block "loading for chef 11 domain" do
      block do
        res = Chef::Resource::Chef::Resource::FmwDomainWlstWindows.new("WLST create domain", run_context )
        res.version             node['fmw']['version']
        res.script_file         "#{node['fmw']['tmp_dir']}/domain.py"
        res.middleware_home_dir node['fmw']['middleware_home_dir']
        res.weblogic_home_dir   node['fmw']['weblogic_home_dir']
        res.java_home_dir       node['fmw']['java_home_dir']
        res.tmp_dir             node['fmw']['tmp_dir']
        res.weblogic_password   domain_params['weblogic_password']
        res.run_action          :execute unless ::File.exists?("#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}/config/config.xml")
      end
    end
  else
    fmw_domain_wlst "WLST create domain" do
      version node['fmw']['version']
      script_file "#{node['fmw']['tmp_dir']}/domain.py"
      middleware_home_dir node['fmw']['middleware_home_dir']
      weblogic_home_dir node['fmw']['weblogic_home_dir']
      java_home_dir node['fmw']['java_home_dir']
      tmp_dir node['fmw']['tmp_dir']
      weblogic_password domain_params['weblogic_password']
      not_if { ::File.exists?("#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}/config/config.xml")}
    end
  end
else
  # add the common utils py script to the tmp dir
  cookbook_file node['fmw']['tmp_dir'] + '/common.py' do
    source 'domain/common.py'
    action :create
    mode 0755
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
  end

  # add the domain py script to the tmp dir
  template node['fmw']['tmp_dir'] + '/domain.py' do
    source 'domain/domain.py'
    mode 0755
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
    variables(weblogic_home_dir:             node['fmw']['weblogic_home_dir'],
              java_home_dir:                 node['fmw']['java_home_dir'],
              wls_base_template:             wls_base_template,
              domain_dir:                    "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}",
              domain_name:                   domain_params['domain_name'],
              weblogic_user:                 domain_params['weblogic_user'],
              adminserver_name:              domain_params['adminserver_name'],
              adminserver_startup_arguments: node['fmw_domain']['adminserver_startup_arguments'],
              adminserver_listen_address:    domain_params['adminserver_listen_address'],
              adminserver_listen_port:       domain_params['adminserver_listen_port'],
              nodemanager_port:              node['fmw_domain']['nodemanager_port'],
              nodemanagers:                  nodemanagers,
              servers:                       servers,
              clusters:                      clusters,
              tmp_dir:                       node['fmw']['tmp_dir'])
  end

  # make sure the domains directory exists
  directory node['fmw_domain']['domains_dir'] do
    mode 0775
    recursive true
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
    action :create
  end

  # create domain
  if VERSION.start_with? '11.'
    ruby_block "loading for chef 11 domain" do
      block do
        res = Chef::Resource::Chef::Resource::FmwDomainWlst.new("WLST create domain", run_context )
        res.version             node['fmw']['version']
        res.script_file         "#{node['fmw']['tmp_dir']}/domain.py"
        res.middleware_home_dir node['fmw']['middleware_home_dir']
        res.weblogic_home_dir   node['fmw']['weblogic_home_dir']
        res.java_home_dir       node['fmw']['java_home_dir']
        res.tmp_dir             node['fmw']['tmp_dir']
        res.os_user             node['fmw']['os_user']
        res.weblogic_password   domain_params['weblogic_password']
        res.run_action          :execute unless ::File.exists?("#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}/config/config.xml")
      end
    end
  else
    fmw_domain_wlst "WLST create domain" do
      version node['fmw']['version']
      script_file "#{node['fmw']['tmp_dir']}/domain.py"
      middleware_home_dir node['fmw']['middleware_home_dir']
      weblogic_home_dir node['fmw']['weblogic_home_dir']
      java_home_dir node['fmw']['java_home_dir']
      tmp_dir node['fmw']['tmp_dir']
      os_user node['fmw']['os_user']
      weblogic_password domain_params['weblogic_password']
      not_if { ::File.exists?("#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}/config/config.xml")}
    end
  end
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
