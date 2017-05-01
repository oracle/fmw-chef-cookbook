#
# Cookbook Name:: fmw_domain
# Recipe:: extension_soa_suite
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

bpm_enabled = false
if node['fmw_domain'].attribute?('soa_suite_install_type')
  unless ['BPM', 'SOA Suite'].include?(node['fmw_domain']['soa_suite_install_type'])
    fail 'unknown soa_suite_install_type please use BPM|SOA Suite'
  end
  bpm_enabled = true if node['fmw_domain']['soa_suite_install_type'] == 'BPM'
end

if ['12.2.1', '12.2.1.1', '12.2.1.2', '12.1.3', '12.1.2'].include?(node['fmw']['version'])
  if node['fmw']['version'] == '12.1.2'
    return
  elsif node['fmw']['version'] == '12.1.3'
    wls_em_template        = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_wls_template_12.1.3.jar"
    wls_jrf_template       = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.jrf_template_12.1.3.jar"
    wls_appl_core_template = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.applcore.model.stub.1.0.0_template.jar"
    wls_wsmpm_template     = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.wsmpm_template_12.1.3.jar"
    wls_soa_template       = "#{node['fmw']['middleware_home_dir']}/soa/common/templates/wls/oracle.soa_template_12.1.3.jar"
    wls_bpm_template       = "#{node['fmw']['middleware_home_dir']}/soa/common/templates/wls/oracle.bpm_template_12.1.3.jar"
    wls_b2b_template       = "#{node['fmw']['middleware_home_dir']}/soa/common/templates/wls/oracle.soa.b2b_template_12.1.3.jar"
  else
    wls_em_template        = "#{node['fmw']['middleware_home_dir']}/em/common/templates/wls/oracle.em_wls_template.jar"
    wls_jrf_template       = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.jrf_template.jar"
    wls_appl_core_template = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.applcore.model.stub_template.jar"
    wls_wsmpm_template     = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/wls/oracle.wsmpm_template.jar"
    wls_soa_template       = "#{node['fmw']['middleware_home_dir']}/soa/common/templates/wls/oracle.soa_template.jar"
    wls_bpm_template       = "#{node['fmw']['middleware_home_dir']}/soa/common/templates/wls/oracle.bpm_template.jar"
    wls_b2b_template       = "#{node['fmw']['middleware_home_dir']}/soa/common/templates/wls/oracle.soa.b2b_template.jar"
  end
elsif ['10.3.6'].include?(node['fmw']['version'])
  wls_em_template        = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/applications/oracle.em_11_1_1_0_0_template.jar"
  wls_jrf_template       = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/applications/jrf_template_11.1.1.jar"
  wls_appl_core_template = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/applications/oracle.applcore.model.stub.11.1.1_template.jar"
  wls_wsmpm_template     = "#{node['fmw']['middleware_home_dir']}/oracle_common/common/templates/applications/oracle.wsmpm_template_11.1.1.jar"
  wls_soa_template       = "#{node['fmw']['middleware_home_dir']}/Oracle_SOA1/common/templates/applications/oracle.soa_template_11.1.1.jar"
  wls_bpm_template       = "#{node['fmw']['middleware_home_dir']}/Oracle_SOA1/common/templates/applications/oracle.bpm_template_11.1.1.jar"
  wls_b2b_template       = ""
end


if node['os'].include?('windows')

  domain_path = "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}".gsub('\\\\', '/').gsub('\\', '/')

  # add the domain py script to the tmp dir
  template node['fmw']['tmp_dir'] + '/soa_suite.py' do
    source 'domain/extensions/soa_suite.py'
    variables(weblogic_home_dir:             node['fmw']['weblogic_home_dir'].gsub('\\\\', '/').gsub('\\', '/'),
              java_home_dir:                 node['fmw']['java_home_dir'].gsub('\\\\', '/').gsub('\\', '/'),
              domain_dir:                    domain_path,
              domain_name:                   domain_params['domain_name'],
              app_dir:                       "#{node['fmw_domain']['apps_dir']}/#{domain_params['domain_name']}".gsub('\\\\', '/').gsub('\\', '/'),
              adminserver_name:              domain_params['adminserver_name'],
              adminserver_listen_address:    domain_params['adminserver_listen_address'],
              nodemanager_port:              node['fmw_domain']['nodemanager_port'],
              tmp_dir:                       node['fmw']['tmp_dir'].gsub('\\\\', '/').gsub('\\', '/'),
              version:                       node['fmw']['version'],
              wls_em_template:               wls_em_template,
              wls_jrf_template:              wls_jrf_template,
              wls_appl_core_template:        wls_appl_core_template,
              wls_wsmpm_template:            wls_wsmpm_template,
              wls_soa_template:              wls_soa_template,
              wls_bpm_template:              wls_bpm_template,
              wls_b2b_template:              wls_b2b_template,
              bpm_enabled:                   bpm_enabled,
              soa_server_startup_arguments:  node['fmw_domain']['soa_server_startup_arguments'],
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

  # add domain extension soa_suite
  fmw_domain_wlst "WLST add soa_suite domain extension" do
    version             node['fmw']['version']
    script_file         "#{node['fmw']['tmp_dir']}/soa_suite.py"
    middleware_home_dir node['fmw']['middleware_home_dir']
    weblogic_home_dir   node['fmw']['weblogic_home_dir']
    java_home_dir       node['fmw']['java_home_dir']
    tmp_dir             node['fmw']['tmp_dir']
    repository_password domain_params['repository_password']
    not_if { ::File.exist?("#{domain_path}/config/config.xml") == true and
             ::File.readlines("#{domain_path}/config/config.xml").grep(/soa-infra/).size > 0 }
  end

  if node['fmw_domain'].attribute?('soa_suite_cluster') and node['fmw']['version'] == '10.3.6'
    # add soa_suite JMS cluster configuration
    fmw_domain_wlst "WLST add soa_suite JMS cluster configuration" do
      version             node['fmw']['version']
      script_file         "#{node['fmw']['middleware_home_dir']}/Oracle_SOA1/bin/soa-createUDD.py --domain_home #{domain_path} --soacluster #{soa_cluster} --create_jms true"
      middleware_home_dir node['fmw']['middleware_home_dir']
      weblogic_home_dir   node['fmw']['weblogic_home_dir']
      java_home_dir       node['fmw']['java_home_dir']
      tmp_dir             node['fmw']['tmp_dir']
      not_if { ::File.exist?("#{domain_path}/config/config.xml") == true and
               ::File.readlines("#{domain_path}/config/config.xml").grep(/<name>SOAJMSModuleUDDs<\/name>/).size > 0 }
    end
  end

else

  domain_path = "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}"

  # add the domain py script to the tmp dir
  template node['fmw']['tmp_dir'] + '/soa_suite.py' do
    source 'domain/extensions/soa_suite.py'
    mode 0755
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
    variables(weblogic_home_dir:             node['fmw']['weblogic_home_dir'],
              java_home_dir:                 node['fmw']['java_home_dir'],
              domain_dir:                    "#{node['fmw_domain']['domains_dir']}/#{domain_params['domain_name']}",
              domain_name:                   domain_params['domain_name'],
              app_dir:                       "#{node['fmw_domain']['apps_dir']}/#{domain_params['domain_name']}",
              adminserver_name:              domain_params['adminserver_name'],
              adminserver_listen_address:    domain_params['adminserver_listen_address'],
              nodemanager_port:              node['fmw_domain']['nodemanager_port'],
              tmp_dir:                       node['fmw']['tmp_dir'],
              version:                       node['fmw']['version'],
              wls_em_template:               wls_em_template,
              wls_jrf_template:              wls_jrf_template,
              wls_appl_core_template:        wls_appl_core_template,
              wls_wsmpm_template:            wls_wsmpm_template,
              wls_soa_template:              wls_soa_template,
              wls_bpm_template:              wls_bpm_template,
              wls_b2b_template:              wls_b2b_template,
              bpm_enabled:                   bpm_enabled,
              soa_server_startup_arguments:  node['fmw_domain']['soa_server_startup_arguments'],
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

  # add domain extension soa_suite
  fmw_domain_wlst "WLST add soa_suite domain extension" do
    version             node['fmw']['version']
    script_file         "#{node['fmw']['tmp_dir']}/soa_suite.py"
    middleware_home_dir node['fmw']['middleware_home_dir']
    weblogic_home_dir   node['fmw']['weblogic_home_dir']
    java_home_dir       node['fmw']['java_home_dir']
    tmp_dir             node['fmw']['tmp_dir']
    os_user             node['fmw']['os_user']
    repository_password domain_params['repository_password']
    not_if { ::File.exist?("#{domain_path}/config/config.xml") == true and
             ::File.readlines("#{domain_path}/config/config.xml").grep(/soa-infra/).size > 0 }
  end

  if node['fmw_domain'].attribute?('soa_suite_cluster') and node['fmw']['version'] == '10.3.6'
    # add soa_suite JMS cluster configuration
    fmw_domain_wlst "WLST add soa_suite JMS cluster configuration" do
      version             node['fmw']['version']
      script_file         "#{node['fmw']['middleware_home_dir']}/Oracle_SOA1/bin/soa-createUDD.py --domain_home #{domain_path} --soacluster #{soa_cluster} --create_jms true"
      middleware_home_dir node['fmw']['middleware_home_dir']
      weblogic_home_dir   node['fmw']['weblogic_home_dir']
      java_home_dir       node['fmw']['java_home_dir']
      tmp_dir             node['fmw']['tmp_dir']
      os_user             node['fmw']['os_user']
      not_if { ::File.exist?("#{domain_path}/config/config.xml") == true and
               ::File.readlines("#{domain_path}/config/config.xml").grep(/<name>SOAJMSModuleUDDs<\/name>/).size > 0 }
    end
  end
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
