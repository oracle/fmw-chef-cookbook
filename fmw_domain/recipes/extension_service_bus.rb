#
# Cookbook Name:: fmw_domain
# Recipe:: extension_service_bus
#
# Copyright 2015 Oracle. All Rights Reserved
#
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"
fail 'databag_key parameter cannot be empty' unless node['fmw_domain'].attribute?('databag_key')

include_recipe 'fmw_domain::domain'
include_recipe 'fmw_inst::service_bus'

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

bpm_enabled = false
if node['fmw_domain'].attribute?('soa_suite_install_type')
  unless ['BPM', 'SOA Suite'].include?(node['fmw_domain']['soa_suite_install_type'])
    fail 'unknown soa_suite_install_type please use BPM|SOA Suite'
  end
  bpm_enabled = true if node['fmw_domain']['soa_suite_install_type'] == 'BPM'
end

if ['12.2.1', '12.2.1.1', '12.1.3', '12.1.2'].include?(node['fmw']['version'])
  if node['fmw']['version'] == '12.1.2'
    return
  elsif node['fmw']['version'] == '12.1.3'
    wls_em_template = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_wls_template_12.1.3.jar"
    wls_sb_template = "#{node['fmw']['middleware_home_dir']}/osb/common/templates/wls/oracle.osb_template_12.1.3.jar"
    wls_ws_template = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.wls-webservice-template_12.1.3.jar"
  else
    wls_em_template = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_wls_template.jar"
    wls_sb_template = "#{node['fmw']['middleware_home_dir']}/osb/common/templates/wls/oracle.osb_template.jar"
    wls_ws_template = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.wls-webservice-template.jar"
  end
elsif ['10.3.6'].include?(node['fmw']['version'])
  wls_em_template = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/applications/oracle.em_11_1_1_0_0_template.jar"
  wls_sb_template = "#{node['fmw']['middleware_home_dir']}/Oracle_OSB1/common/templates/applications/wlsb.jar"
  wls_ws_template = "#{node['fmw']['weblogic_home_dir']}/common/templates/applications/wls_webservice.jar"
end

if node['os'].include?('windows')

  domain_path = "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}".gsub('\\\\', '/').gsub('\\', '/')

  # add the domain py script to the tmp dir
  template node['fmw']['tmp_dir'] + '/service_bus.py' do
    source 'domain/extensions/service_bus.py'
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
              wls_sb_template:               wls_sb_template,
              wls_ws_template:               wls_ws_template,
              osb_server_startup_arguments:  node['fmw_domain']['osb_server_startup_arguments'],
              bam_cluster:                   bam_cluster,
              osb_cluster:                   osb_cluster,
              ess_cluster:                   ess_cluster,
              soa_cluster:                   soa_cluster,
              bpm_enabled:                   bpm_enabled,
              repository_database_url:       domain_params['repository_database_url'],
              repository_prefix:             domain_params['repository_prefix']
              )
  end

  # make sure the domains directory exists
  directory node['fmw_domain']['apps_dir'] do
    recursive true
    action :create
  end

  # add domain extension service_bus
  if VERSION.start_with? '11.'
    ruby_block "loading for chef 11 extension service_bus" do
      block do
        res = Chef::Resource::Chef::Resource::FmwDomainWlstWindows.new( "WLST add service_bus domain extension", run_context )
        res.version             node['fmw']['version']
        res.script_file         "#{node['fmw']['tmp_dir']}/service_bus.py"
        res.middleware_home_dir node['fmw']['middleware_home_dir']
        res.weblogic_home_dir   node['fmw']['weblogic_home_dir']
        res.java_home_dir       node['fmw']['java_home_dir']
        res.tmp_dir             node['fmw']['tmp_dir']
        res.repository_password domain_params['repository_password']
        res.run_action          :execute unless ::File.exist?("#{domain_path}/config/config.xml") == true and (::File.readlines("#{domain_path}/config/config.xml").grep(/osb.em/).size > 0 or ::File.readlines("#{domain_path}/config/config.xml").grep(/ALSB/).size > 0 )
      end
    end
  else
    fmw_domain_wlst "WLST add service_bus domain extension" do
      version             node['fmw']['version']
      script_file         "#{node['fmw']['tmp_dir']}/service_bus.py"
      middleware_home_dir node['fmw']['middleware_home_dir']
      weblogic_home_dir   node['fmw']['weblogic_home_dir']
      java_home_dir       node['fmw']['java_home_dir']
      tmp_dir             node['fmw']['tmp_dir']
      repository_password domain_params['repository_password']
      not_if {  ::File.exist?("#{domain_path}/config/config.xml") == true and
               (::File.readlines("#{domain_path}/config/config.xml").grep(/osb.em/).size > 0 or 
                ::File.readlines("#{domain_path}/config/config.xml").grep(/ALSB/).size > 0 ) }
    end
  end

  if node['fmw']['version'] == '10.3.6'
    powershell_script 'change ALSB_DEBUG_FLAG' do
      code "$c = Get-Content #{domain_path}/bin/setDomainEnv.cmd; $c | %{$_ -replace 'set ALSB_DEBUG_FLAG=true','set ALSB_DEBUG_FLAG=false'} | Set-Content #{domain_path}/bin/setDomainEnv.cmd"
      not_if { ::File.exist?("#{domain_path}/bin/setDomainEnv.cmd") == true and
               ::File.readlines("#{domain_path}/bin/setDomainEnv.cmd").grep(/set ALSB_DEBUG_FLAG=false/).size > 0 }
    end
    powershell_script 'change debugFlag' do
      code "$c = Get-Content #{domain_path}/bin/setDomainEnv.cmd; $c | %{$_ -replace 'set debugFlag=true','set debugFlag=false'} | Set-Content #{domain_path}/bin/setDomainEnv.cmd"
      not_if { ::File.exist?("#{domain_path}/bin/setDomainEnv.cmd") == true and
               ::File.readlines("#{domain_path}/bin/setDomainEnv.cmd").grep(/set debugFlag=false/).size > 2 }
    end
    powershell_script 'change DERBY_FLAG' do
      code "$c = Get-Content #{domain_path}/bin/setDomainEnv.cmd; $c | %{$_ -replace 'set DERBY_FLAG=true','set DERBY_FLAG=false'} | Set-Content #{domain_path}/bin/setDomainEnv.cmd"
      not_if { ::File.exist?("#{domain_path}/bin/setDomainEnv.cmd") == true and
               ::File.readlines("#{domain_path}/bin/setDomainEnv.cmd").grep(/set DERBY_FLAG=false/).size > 1 }
    end
  end

else

  domain_path = "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}"

  # add the domain py script to the tmp dir
  template node['fmw']['tmp_dir'] + '/service_bus.py' do
    source 'domain/extensions/service_bus.py'
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
              wls_sb_template:               wls_sb_template,
              wls_ws_template:               wls_ws_template,
              osb_server_startup_arguments:  node['fmw_domain']['osb_server_startup_arguments'],
              bam_cluster:                   bam_cluster,
              osb_cluster:                   osb_cluster,
              ess_cluster:                   ess_cluster,
              soa_cluster:                   soa_cluster,
              bpm_enabled:                   bpm_enabled,
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

  # add domain extension service_bus
  if VERSION.start_with? '11.'
    ruby_block "loading for chef 11 extension service_bus" do
      block do
        res = Chef::Resource::Chef::Resource::FmwDomainWlst.new("WLST add service_bus domain extension", run_context )
        res.version             node['fmw']['version']
        res.script_file         "#{node['fmw']['tmp_dir']}/service_bus.py"
        res.middleware_home_dir node['fmw']['middleware_home_dir']
        res.weblogic_home_dir   node['fmw']['weblogic_home_dir']
        res.java_home_dir       node['fmw']['java_home_dir']
        res.tmp_dir             node['fmw']['tmp_dir']
        res.os_user             node['fmw']['os_user']
        res.repository_password domain_params['repository_password']
        res.run_action          :execute unless  ::File.exist?("#{domain_path}/config/config.xml") == true and (::File.readlines("#{domain_path}/config/config.xml").grep(/osb.em/).size > 0 or ::File.readlines("#{domain_path}/config/config.xml").grep(/ALSB/).size > 0 ) 
      end
    end
  else
    fmw_domain_wlst "WLST add service_bus domain extension" do
      version             node['fmw']['version']
      script_file         "#{node['fmw']['tmp_dir']}/service_bus.py"
      middleware_home_dir node['fmw']['middleware_home_dir']
      weblogic_home_dir   node['fmw']['weblogic_home_dir']
      java_home_dir       node['fmw']['java_home_dir']
      tmp_dir             node['fmw']['tmp_dir']
      os_user             node['fmw']['os_user']
      repository_password domain_params['repository_password']
      not_if {  ::File.exist?("#{domain_path}/config/config.xml") == true and
               (::File.readlines("#{domain_path}/config/config.xml").grep(/osb.em/).size > 0 or 
                ::File.readlines("#{domain_path}/config/config.xml").grep(/ALSB/).size > 0 ) }
    end
  end

  if node['fmw']['version'] == '10.3.6'
    execute 'change ALSB_DEBUG_FLAG' do
      command "sed -i -e's/ALSB_DEBUG_FLAG=\"true\"/ALSB_DEBUG_FLAG=\"false\"/g' #{domain_path}/bin/setDomainEnv.sh"
      not_if { ::File.exist?("#{domain_path}/bin/setDomainEnv.sh") == true and
               ::File.readlines("#{domain_path}/bin/setDomainEnv.sh").grep(/set ALSB_DEBUG_FLAG=false/).size > 0 }
    end
    execute 'change debugFlag' do
      command "sed -i -e's/debugFlag=\"true\"/debugFlag=\"false\"/g' #{domain_path}/bin/setDomainEnv.sh"
      not_if { ::File.exist?("#{domain_path}/bin/setDomainEnv.sh") == true and
               ::File.readlines("#{domain_path}/bin/setDomainEnv.sh").grep(/set debugFlag=false/).size > 2 }
    end
    execute 'change DERBY_FLAG' do
      command "sed -i -e's/DERBY_FLAG=\"true\"/DERBY_FLAG=\"false\"/g' #{domain_path}/bin/setDomainEnv.sh"
      not_if { ::File.exist?("#{domain_path}/bin/setDomainEnv.sh") == true and
               ::File.readlines("#{domain_path}/bin/setDomainEnv.sh").grep(/set DERBY_FLAG=false/).size > 1 }
    end
  end

end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
