#
# Cookbook Name:: fmw_domain
# Recipe:: nodemanager
#
# Copyright 2015 Oracle. All Rights Reserved
#
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

fail 'nodemanager_listen_address parameter cannot be empty' unless node['fmw_domain'].attribute?('nodemanager_listen_address')
fail 'databag_key parameter cannot be empty' unless node['fmw_domain'].attribute?('databag_key')

include_recipe 'fmw_domain::domain'

domain_params =  begin
                data_bag_item('fmw_domains',node['fmw_domain']['databag_key'])
              rescue Net::HTTPServerException, Chef::Exceptions::ValidationFailed, Chef::Exceptions::InvalidDataBagPath
                [] # empty array for length comparison
              end
domain_params = domain_params.to_hash if domain_params.instance_of? Chef::EncryptedDataBagItem

fail 'did not find the data_bag_item' if domain_params.length == 0

if ['10.3.6'].include?(node['fmw']['version'])
  nodemanager_home_dir  = "#{node['fmw']['weblogic_home_dir']}/common/nodemanager"
  bin_dir               = "#{node['fmw']['weblogic_home_dir']}/server/bin"
  nodemanager_template  = 'nodemanager.properties_11g'
  nodemanager_check     = node['fmw']['weblogic_home_dir']
  if node['fmw']['prod_name'].nil? or node['fmw']['prod_name'] == ''
    script_name           = "nodemanager_11g"
  else
    script_name           = "#{node['fmw']['prod_name']}_nodemanager_11g"
  end
else
  nodemanager_home_dir  = "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}/nodemanager"
  bin_dir               = "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}/bin"
  nodemanager_template  = 'nodemanager.properties_12c'
  nodemanager_check     = "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}"
  if node['fmw']['prod_name'].nil? or node['fmw']['prod_name'] == ''
    script_name           = "nodemanager_11g"
  else
    script_name           = "#{node['fmw']['prod_name']}_nodemanager_#{domain_params['domain_name']}"
  end
end

nodemanager_log_file  = "#{nodemanager_home_dir}/nodemanager.log"
nodemanager_lock_file = "#{nodemanager_home_dir}/nodemanager.log.lck"

if node['os'].include?('windows')
  # update or add the nodemanager.properties
  template "#{nodemanager_home_dir}/nodemanager.properties" do
    source "nodemanager/#{nodemanager_template}"
    variables(weblogic_home_dir:             node['fmw']['weblogic_home_dir'].gsub('\\\\', '/').gsub('\\', '/'),
              java_home_dir:                 node['fmw']['java_home_dir'].gsub('\\\\', '/').gsub('\\', '/'),
              nodemanager_log_dir:           nodemanager_log_file.gsub('\\\\', '/').gsub('\\', '/'),
              domain_dir:                    "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}".gsub('\\\\', '/').gsub('\\', '/'),
              nodemanager_address:           node['fmw_domain']['nodemanager_listen_address'],
              nodemanager_port:              node['fmw_domain']['nodemanager_port'],
              nodemanager_secure_listener:   true,
              platform_family:               node['platform_family'],
              version:                       node['fmw']['version'])
  end
else
  # update or add the nodemanager.properties
  template "#{nodemanager_home_dir}/nodemanager.properties" do
    source "nodemanager/#{nodemanager_template}"
    mode 0755
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
    variables(weblogic_home_dir:             node['fmw']['weblogic_home_dir'],
              java_home_dir:                 node['fmw']['java_home_dir'],
              nodemanager_log_dir:           nodemanager_log_file,
              domain_dir:                    "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}",
              nodemanager_address:           node['fmw_domain']['nodemanager_listen_address'],
              nodemanager_port:              node['fmw_domain']['nodemanager_port'],
              nodemanager_secure_listener:   true,
              platform_family:               node['platform_family'],
              version:                       node['fmw']['version'])
  end
end

# create a nodemanager service so we can start it in the background
if node['os'].include?('linux')

  if (node['platform_family'] == 'rhel' and node['platform_version'] >= '7.0')
    location = "#{node['fmw']['user_home_dir']}/#{node['fmw']['os_user']}/#{script_name}"
  else
    location = "/etc/init.d/#{script_name}"
  end

  # add linux script to the right location
  template location do
    source 'nodemanager/nodemanager'
    mode 0755
    variables(platform_family:             node['platform_family'],
              nodemanager_lock_file:       nodemanager_lock_file,
              nodemanager_bin_path:        bin_dir,
              nodemanager_check:           nodemanager_check,
              os_user:                     node['fmw']['os_user'])
  end

  if VERSION.start_with? '11.'
    ruby_block "loading for chef 11 nodemanager" do
      block do
        res = Chef::Resource::Chef::Resource::FmwDomainNodemanagerServiceRedhat.new(script_name, run_context )  if (node['platform_family'] == 'rhel' and node['platform_version'] < '7.0')
        res = Chef::Resource::Chef::Resource::FmwDomainNodemanagerServiceRedhat7.new(script_name, run_context ) if (node['platform_family'] == 'rhel' and node['platform_version'] >= '7.0')
        res = Chef::Resource::Chef::Resource::FmwDomainNodemanagerServiceDebian.new(script_name, run_context )  if (node['platform_family'] == 'debian')
        res.user_home_dir node['fmw']['user_home_dir']
        res.os_user       node['fmw']['os_user']
        res.run_action    :configure
      end
    end
  else
    fmw_domain_nodemanager_service script_name do
      user_home_dir node['fmw']['user_home_dir']
      os_user       node['fmw']['os_user']
    end
  end
elsif node['os'].include?('solaris2')

  if VERSION.start_with? '11.'
    ruby_block "loading for chef 11 nodemanager" do
      block do
        res = Chef::Resource::Chef::Resource::FmwDomainNodemanagerServiceSolaris.new(script_name, run_context )
        res.bin_dir      bin_dir
        res.tmp_dir      node['fmw']['tmp_dir']
        res.os_user      node['fmw']['os_user']
        res.service_name script_name
        res.run_action   :configure
      end
    end
  else
    fmw_domain_nodemanager_service script_name do
      bin_dir bin_dir
      tmp_dir node['fmw']['tmp_dir']
      os_user node['fmw']['os_user']
      service_name script_name
    end
  end
elsif node['os'].include?('windows')

  if VERSION.start_with? '11.'
    ruby_block "loading for chef 11 nodemanager" do
      block do
        res = Chef::Resource::Chef::Resource::FmwDomainNodemanagerServiceWindows.new(script_name, run_context )
        res.domain_dir          "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}"
        res.domain_name         domain_params['domain_name']
        res.version             node['fmw']['version']
        res.middleware_home_dir node['fmw']['middleware_home_dir']
        res.bin_dir             bin_dir
        res.java_home_dir       node['fmw']['java_home_dir']
        res.prod_name           node['fmw']['prod_name']
        res.service_description node['fmw_domain']['nodemanager_service_description']
        res.run_action          :configure
      end
    end
  else
    fmw_domain_nodemanager_service script_name do
      domain_dir          "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}"
      domain_name         domain_params['domain_name']
      version             node['fmw']['version']
      middleware_home_dir node['fmw']['middleware_home_dir']
      bin_dir             bin_dir
      java_home_dir       node['fmw']['java_home_dir']
      prod_name           node['fmw']['prod_name']
      service_description node['fmw_domain']['nodemanager_service_description']
    end
  end

end

if node['os'].include?('windows')
  netstat_cmd = "netstat -an |find /i \"listening\""
  netstat_column = 1

elsif node['os'].include?('solaris2')
  netstat_cmd = "netstat -an | grep LISTEN"
  netstat_column = 0

else
  netstat_cmd = "netstat -an | grep LISTEN"
  netstat_column = 3
end

ruby_block "block_until_operational" do
  block do
    i = 1
    until DomainHelper.listening?(netstat_cmd, node['fmw_domain']['nodemanager_port'], netstat_column)
      Chef::Log.info("#{script_name} not active yet (port #{node['fmw_domain']['nodemanager_port']})")
      sleep 2
      i += 1
      fail 'nodemanager startup takes too long' if  i > 30
    end
  end
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
