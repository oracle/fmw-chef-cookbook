#
# Cookbook Name:: fmw_domain
# Recipe:: extension_enterprise_scheduler
#
# Copyright 2015 Oracle. All Rights Reserved
#
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"
fail 'databag_key parameter cannot be empty' unless node['fmw_domain'].attribute?('databag_key')

include_recipe 'fmw_domain::domain'
include_recipe 'fmw_inst::soa_suite'

domain_params =  begin
                data_bag_item('fmw_domains',node['fmw_domain']['databag_key'])
              rescue Net::HTTPServerException, Chef::Exceptions::ValidationFailed, Chef::Exceptions::InvalidDataBagPath
                [] # empty array for length comparison
              end
domain_params = domain_params.to_hash if domain_params.instance_of? Chef::EncryptedDataBagItem

fail 'did not find the data_bag_item' if domain_params.length == 0

if node['fmw_domain'].attribute?('enterprise_scheduler_cluster')
  ess_cluster = node['fmw_domain']['enterprise_scheduler_cluster']
else
  ess_cluster = ''
end

if node['fmw_domain'].attribute?('service_bus_cluster')
  osb_cluster = node['fmw_domain']['service_bus_cluster']
else
  osb_cluster = ''
end

if node['fmw_domain'].attribute?('soa_suite_cluster')
  soa_cluster = node['fmw_domain']['soa_suite_cluster']
else
  soa_cluster = ''
end

if node['fmw_domain'].attribute?('bam_cluster')
  bam_cluster = node['fmw_domain']['bam_cluster']
else
  bam_cluster = ''
end

if ['12.2.1', '12.1.3', '12.1.2'].include?(node['fmw']['version'])
  if node['fmw']['version'] == '12.1.2'
    return
  elsif node['fmw']['version'] == '12.1.3'
    wls_em_template = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_wls_template_12.1.3.jar"
    wls_ess_em_template = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_ess_template_12.1.3.jar"
    wls_ess_template = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.ess.basic_template_12.1.3.jar"
  else
    wls_em_template = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_wls_template.jar"
    wls_ess_em_template = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_ess_template.jar"
    wls_ess_template = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.ess.basic_template.jar"
  end
else
  return
end

if node['os'].include?('windows')

  domain_path = "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}".gsub('\\\\', '/').gsub('\\', '/')

  # add the domain py script to the tmp dir
  template node['fmw']['tmp_dir'] + '/enterprise_scheduler.py' do
    source 'domain/extensions/enterprise_scheduler.py'
    variables(weblogic_home_dir:             node['fmw']['weblogic_home_dir'].gsub('\\\\', '/').gsub('\\', '/'),
              java_home_dir:                 node['fmw']['java_home_dir'].gsub('\\\\', '/').gsub('\\', '/'),
              domain_dir:                    domain_path,
              domain_name:                   domain_params['domain_name'],
              app_dir:                       "#{node['fmw_domain']['apps_dir']}/#{domain_params['domain_name']}".gsub('\\\\', '/').gsub('\\', '/'),
              adminserver_name:              domain_params['adminserver_name'],
              adminserver_listen_address:    domain_params['adminserver_listen_address'],
              tmp_dir:                       node['fmw']['tmp_dir'].gsub('\\\\', '/').gsub('\\', '/'),
              version:                       node['fmw']['version'],
              wls_em_template:               wls_em_template,
              wls_ess_em_template:           wls_ess_em_template,
              wls_ess_template:              wls_ess_template,
              ess_server_startup_arguments:  node['fmw_domain']['ess_server_startup_arguments'],
              bam_cluster:                   bam_cluster,
              osb_cluster:                   osb_cluster,
              ess_cluster:                   ess_cluster,
              soa_cluster:                   soa_cluster,
              repository_database_url:       domain_params['repository_database_url'],
              repository_prefix:             domain_params['repository_prefix']
              )
  end

  # make sure the domains directory exists
  directory node['fmw_domain']['apps_dir'] do
    recursive true
    action :create
  end

  # add domain extension enterprise_scheduler
  if VERSION.start_with? '11.'
    ruby_block "loading for chef 11 extension enterprise_scheduler" do
      block do
        res = Chef::Resource::Chef::Resource::FmwDomainWlstWindows.new("WLST add enterprise_scheduler domain extension", run_context )
        res.version             node['fmw']['version']
        res.script_file         "#{node['fmw']['tmp_dir']}/enterprise_scheduler.py"
        res.middleware_home_dir node['fmw']['middleware_home_dir']
        res.weblogic_home_dir   node['fmw']['weblogic_home_dir']
        res.java_home_dir       node['fmw']['java_home_dir']
        res.tmp_dir             node['fmw']['tmp_dir']
        res.repository_password domain_params['repository_password']
        res.run_action          :execute unless ::File.exist?("#{domain_path}/config/config.xml") == true and ::File.readlines("#{domain_path}/config/config.xml").grep(/oracle.ess.runtime/).size > 0
      end
    end
  else
    fmw_domain_wlst "WLST add enterprise_scheduler domain extension" do
      version             node['fmw']['version']
      script_file         "#{node['fmw']['tmp_dir']}/enterprise_scheduler.py"
      middleware_home_dir node['fmw']['middleware_home_dir']
      weblogic_home_dir   node['fmw']['weblogic_home_dir']
      java_home_dir       node['fmw']['java_home_dir']
      tmp_dir             node['fmw']['tmp_dir']
      repository_password domain_params['repository_password']
      not_if {  ::File.exist?("#{domain_path}/config/config.xml") == true and
                ::File.readlines("#{domain_path}/config/config.xml").grep(/oracle.ess.runtime/).size > 0  }
    end
  end
else

  domain_path = "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}"

  # add the domain py script to the tmp dir
  template node['fmw']['tmp_dir'] + '/enterprise_scheduler.py' do
    source 'domain/extensions/enterprise_scheduler.py'
    mode 0755
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
    variables(weblogic_home_dir:             node['fmw']['weblogic_home_dir'],
              java_home_dir:                 node['fmw']['java_home_dir'],
              domain_dir:                    domain_path,
              domain_name:                   domain_params['domain_name'],
              app_dir:                       "#{node['fmw_domain']['apps_dir']}/#{domain_params['domain_name']}",
              adminserver_name:              domain_params['adminserver_name'],
              adminserver_listen_address:    domain_params['adminserver_listen_address'],
              tmp_dir:                       node['fmw']['tmp_dir'],
              version:                       node['fmw']['version'],
              wls_em_template:               wls_em_template,
              wls_ess_em_template:           wls_ess_em_template,
              wls_ess_template:              wls_ess_template,
              ess_server_startup_arguments:  node['fmw_domain']['ess_server_startup_arguments'],
              bam_cluster:                   bam_cluster,
              osb_cluster:                   osb_cluster,
              ess_cluster:                   ess_cluster,
              soa_cluster:                   soa_cluster,
              repository_database_url:       domain_params['repository_database_url'],
              repository_prefix:             domain_params['repository_prefix']
              )
  end

  # make sure the domains directory exists
  directory node['fmw_domain']['apps_dir'] do
    mode 0775
    recursive true
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
    action :create
  end

  # add domain extension enterprise_scheduler
  if VERSION.start_with? '11.'
    ruby_block "loading for chef 11 extension enterprise_scheduler" do
      block do
        res = Chef::Resource::Chef::Resource::FmwDomainWlst.new("WLST add enterprise_scheduler domain extension", run_context )
        res.version             node['fmw']['version']
        res.script_file         "#{node['fmw']['tmp_dir']}/enterprise_scheduler.py"
        res.middleware_home_dir node['fmw']['middleware_home_dir']
        res.weblogic_home_dir   node['fmw']['weblogic_home_dir']
        res.java_home_dir       node['fmw']['java_home_dir']
        res.tmp_dir             node['fmw']['tmp_dir']
        res.os_user             node['fmw']['os_user']
        res.repository_password domain_params['repository_password']
        res.run_action          :execute unless ::File.exist?("#{domain_path}/config/config.xml") == true and ::File.readlines("#{domain_path}/config/config.xml").grep(/oracle.ess.runtime/).size > 0
      end
    end
  else
    fmw_domain_wlst "WLST add enterprise_scheduler domain extension" do
      version             node['fmw']['version']
      script_file         "#{node['fmw']['tmp_dir']}/enterprise_scheduler.py"
      middleware_home_dir node['fmw']['middleware_home_dir']
      weblogic_home_dir   node['fmw']['weblogic_home_dir']
      java_home_dir       node['fmw']['java_home_dir']
      tmp_dir             node['fmw']['tmp_dir']
      os_user             node['fmw']['os_user']
      repository_password domain_params['repository_password']
      not_if {  ::File.exist?("#{domain_path}/config/config.xml") == true and
                ::File.readlines("#{domain_path}/config/config.xml").grep(/oracle.ess.runtime/).size > 0  }
    end
  end
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
