#
# Cookbook Name:: fmw_domain
# Spec:: extension_service_bus
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_domain::extension_soa_suite' do

  context 'When all attributes are default, 12.1.3, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw']['weblogic_home_dir']           = '/opt/oracle/middleware_xxx/wlserver'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = '/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
        node.set['fmw_inst']['service_bus_source_file'] = '/software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
        node.set['fmw_rcu']['oracle_home_dir']         = '/opt/oracle/middleware_xxx/oracle_common'
        node.set['fmw_rcu']['jdbc_database_url']       = 'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com'
        node.set['fmw_rcu']['db_database_url']         = '10.10.10.15:1521:soarepos.example.com'
        node.set['fmw_rcu']['rcu_prefix']              = 'DEVXX'
        node.set['fmw_rcu']['databag_key']             = 'entry1'
        node.set['fmw_domain']['domains_dir']          = '/opt/oracle/middleware_xxx/user_projects/domains'
        node.set['fmw_domain']['apps_dir']             = '/opt/oracle/middleware_xxx/user_projects/applications'
        node.set['fmw_domain']['databag_key']          = 'entry1'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                                 db_sys_password: 'Welcome01',
                                                                 rcu_component_password: 'Welcome02' })

      stub_data_bag_item("fmw_domains", "entry1").and_return({ id:                         'entry1',
                                                               domain_name:                'base',
                                                               weblogic_user:              'weblogic',
                                                               weblogic_password:          'Welcome01',
                                                               adminserver_name:           'AdminServer',
                                                               adminserver_listen_address: '192.168.2.101',
                                                               adminserver_listen_port:    '7001',
                                                               repository_database_url:    "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
                                                               repository_prefix:          "DEVXX",
                                                               repository_password:        "Welcome02"
                                                               })
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_domain::domain')
      expect(chef_run).to include_recipe('fmw_inst::soa_suite')

      expect(chef_run).to create_template('/tmp/soa_suite.py').with(
        source: 'domain/extensions/soa_suite.py',
        owner: 'oracle',
        group: 'oinstall',
        variables: 
          {
             :weblogic_home_dir=>"/opt/oracle/middleware_xxx/wlserver", 
             :java_home_dir=>"/usr/java/jdk1.7.0_75", 
             :domain_dir=>"/opt/oracle/middleware_xxx/user_projects/domains/base", 
             :domain_name=>"base",
             :app_dir=>"/opt/oracle/middleware_xxx/user_projects/applications/base", 
             :adminserver_name=>"AdminServer", 
             :adminserver_listen_address=>"192.168.2.101", 
             :nodemanager_port=>5556,
             :tmp_dir=>"/tmp", 
             :version=>"12.1.3", :wls_em_template=>"/opt/oracle/middleware_xxx/em/common/templates/wls/oracle.em_wls_template_12.1.3.jar", 
             :wls_jrf_template=>"/opt/oracle/middleware_xxx/oracle_common/common/templates/wls/oracle.jrf_template_12.1.3.jar", 
             :wls_appl_core_template=>"/opt/oracle/middleware_xxx/oracle_common/common/templates/wls/oracle.applcore.model.stub.1.0.0_template.jar", 
             :wls_wsmpm_template=>"/opt/oracle/middleware_xxx/oracle_common/common/templates/wls/oracle.wsmpm_template_12.1.3.jar", 
             :wls_soa_template=>"/opt/oracle/middleware_xxx/soa/common/templates/wls/oracle.soa_template_12.1.3.jar", 
             :wls_bpm_template=>"/opt/oracle/middleware_xxx/soa/common/templates/wls/oracle.bpm_template_12.1.3.jar", 
             :wls_b2b_template=>"/opt/oracle/middleware_xxx/soa/common/templates/wls/oracle.soa.b2b_template_12.1.3.jar", 
             :bpm_enabled=>false, 
             :soa_server_startup_arguments=>"-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Djava.security.egd=file:/dev/./urandom", 
             :bam_cluster=>"", 
             :osb_cluster=>"", 
             :ess_cluster=>"", 
             :soa_cluster=>"", 
             :repository_database_url=>"jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com", 
             :repository_prefix=>"DEVXX", 
          }
      )
      expect(chef_run).to create_directory('/opt/oracle/middleware_xxx/user_projects/applications').with(
        recursive: true,
        owner: 'oracle',
        group: 'oinstall'
      )
      expect(chef_run).to execute_fmw_domain_wlst('WLST add soa_suite domain extension').with(
        script_file: '/tmp/soa_suite.py',
        middleware_home_dir: "/opt/oracle/middleware_xxx",
        weblogic_home_dir: "/opt/oracle/middleware_xxx/wlserver",
        java_home_dir: '/usr/java/jdk1.7.0_75',
        tmp_dir: '/tmp',
        os_user: 'oracle'
      )
    end
  end

  context 'When all attributes are default, 12.1.3, on Windows' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2') do |node|
        node.set['fmw']['java_home_dir']               = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = 'c:\\oracle\\middleware_xxx'
        node.set['fmw']['weblogic_home_dir']           = 'c:\\oracle\\middleware_xxx\\wlserver'
        node.set['fmw_jdk']['source_file']             = 'c:\\software\\jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file']             = 'c:\\software\\fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = 'c:\\software\\fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
        node.set['fmw_inst']['service_bus_source_file'] = 'c:\\software\\fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
        node.set['fmw_rcu']['oracle_home_dir']         = '/opt/oracle/middleware_xxx/oracle_common'
        node.set['fmw_rcu']['jdbc_database_url']       = 'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com'
        node.set['fmw_rcu']['db_database_url']         = '10.10.10.15:1521:soarepos.example.com'
        node.set['fmw_rcu']['rcu_prefix']              = 'DEVXX'
        node.set['fmw_rcu']['databag_key']             = 'entry1'
        node.set['fmw_domain']['domains_dir']          = 'c:\\oracle\\middleware_xxx\\user_projects\\domains'
        node.set['fmw_domain']['apps_dir']             = 'c:\\oracle\\middleware_xxx\\user_projects\\applications'
        node.set['fmw_domain']['databag_key']          = 'entry1'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                                 db_sys_password: 'Welcome01',
                                                                 rcu_component_password: 'Welcome02' })



      stub_data_bag_item("fmw_domains", "entry1").and_return({ id:                         'entry1',
                                                               domain_name:                'base',
                                                               weblogic_user:              'weblogic',
                                                               weblogic_password:          'Welcome01',
                                                               adminserver_name:           'AdminServer',
                                                               adminserver_listen_address: '192.168.2.101',
                                                               adminserver_listen_port:    '7001' ,
                                                               repository_database_url:    "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
                                                               repository_prefix:          "DEV1",
                                                               repository_password:        "Welcome02"
                                                               })
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_domain::domain')
      expect(chef_run).to include_recipe('fmw_inst::soa_suite')


      expect(chef_run).to create_template('C:/temp/soa_suite.py').with(
        source: 'domain/extensions/soa_suite.py',
        variables:   {
          :weblogic_home_dir=>"c:/oracle/middleware_xxx/wlserver", 
          :java_home_dir=>"c:/java/jdk1.7.0_75", 
          :domain_dir=>"c:/oracle/middleware_xxx/user_projects/domains/base", 
          :domain_name=>"base", 
          :app_dir=>"c:/oracle/middleware_xxx/user_projects/applications/base", 
          :adminserver_name=>"AdminServer", 
          :adminserver_listen_address=>"192.168.2.101", 
          :nodemanager_port=>5556,
          :tmp_dir=>"C:/temp", 
          :version=>"12.1.3", 
          :wls_em_template=>"c:\\oracle\\middleware_xxx/em/common/templates/wls/oracle.em_wls_template_12.1.3.jar", 
          :wls_jrf_template=>"c:\\oracle\\middleware_xxx/oracle_common/common/templates/wls/oracle.jrf_template_12.1.3.jar", 
          :wls_appl_core_template=>"c:\\oracle\\middleware_xxx/oracle_common/common/templates/wls/oracle.applcore.model.stub.1.0.0_template.jar", 
          :wls_wsmpm_template=>"c:\\oracle\\middleware_xxx/oracle_common/common/templates/wls/oracle.wsmpm_template_12.1.3.jar", 
          :wls_soa_template=>"c:\\oracle\\middleware_xxx/soa/common/templates/wls/oracle.soa_template_12.1.3.jar", 
          :wls_bpm_template=>"c:\\oracle\\middleware_xxx/soa/common/templates/wls/oracle.bpm_template_12.1.3.jar", 
          :wls_b2b_template=>"c:\\oracle\\middleware_xxx/soa/common/templates/wls/oracle.soa.b2b_template_12.1.3.jar", 
          :bpm_enabled=>false, 
          :soa_server_startup_arguments=>"-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m", 
          :bam_cluster=>"", 
          :osb_cluster=>"", 
          :ess_cluster=>"", 
          :soa_cluster=>"", 
          :repository_database_url=>"jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com", 
          :repository_prefix=>"DEV1", 
        }
      )
      expect(chef_run).to create_directory('c:\\oracle\\middleware_xxx\\user_projects\\applications').with(
        recursive: true
      )
      expect(chef_run).to execute_fmw_domain_wlst('WLST add soa_suite domain extension').with(
        script_file: 'C:/temp/soa_suite.py',
        middleware_home_dir: "c:\\oracle\\middleware_xxx",
        weblogic_home_dir: "c:\\oracle\\middleware_xxx\\wlserver",
        java_home_dir: 'c:\\java\\jdk1.7.0_75',
        tmp_dir: 'C:/temp'
      )

    end
  end

  context 'When all attributes are default, 10.3.6, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw']['weblogic_home_dir']            = '/opt/oracle/middleware_xxx/wlserver_10.3'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_inst']['service_bus_source_file'] = '/software/ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip'
        node.set['fmw_inst']['soa_suite_source_file']   = '/software/ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip'
        node.set['fmw_inst']['soa_suite_source_2_file'] = '/software/ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip'
        node.set['fmw_rcu']['source_file']              = '/software/ofm_rcu_linux_11.1.1.7.0_64_disk1_1of1.zip'
        node.set['fmw_rcu']['jdbc_database_url']        = 'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com'
        node.set['fmw_rcu']['db_database_url']          = '10.10.10.15:1521:soarepos.example.com'
        node.set['fmw_rcu']['rcu_prefix']               = 'DEVXX'
        node.set['fmw_rcu']['databag_key']              = 'entry1'
        node.set['fmw_domain']['domains_dir']           = '/opt/oracle/middleware_xxx/user_projects/domains'
        node.set['fmw_domain']['apps_dir']              = '/opt/oracle/middleware_xxx/user_projects/applications'
        node.set['fmw_domain']['databag_key']           = 'entry1'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                                 db_sys_password: 'Welcome01',
                                                                 rcu_component_password: 'Welcome02' })



      stub_data_bag_item("fmw_domains", "entry1").and_return({ id:                         'entry1',
                                                               domain_name:                'base',
                                                               weblogic_user:              'weblogic',
                                                               weblogic_password:          'Welcome01',
                                                               adminserver_name:           'AdminServer',
                                                               adminserver_listen_address: '192.168.2.101',
                                                               adminserver_listen_port:    '7001' ,
                                                               repository_database_url:    "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
                                                               repository_prefix:          "DEV1",
                                                               repository_password:        "Welcome02"
                                                               })
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_domain::domain')
      expect(chef_run).to include_recipe('fmw_inst::soa_suite')

      expect(chef_run).to create_template('/tmp/soa_suite.py').with(
        source: 'domain/extensions/soa_suite.py',
        owner: 'oracle',
        group: 'oinstall',
        variables: 
          {
            :weblogic_home_dir=>"/opt/oracle/middleware_xxx/wlserver_10.3", 
            :java_home_dir=>"/usr/java/jdk1.7.0_75", 
            :domain_dir=>"/opt/oracle/middleware_xxx/user_projects/domains/base", 
            :domain_name=>"base", 
            :app_dir=>"/opt/oracle/middleware_xxx/user_projects/applications/base", 
            :adminserver_name=>"AdminServer", 
            :adminserver_listen_address=>"192.168.2.101", 
            :nodemanager_port=>5556,
            :tmp_dir=>"/tmp", 
            :version=>"10.3.6", 
            :wls_em_template=>"/opt/oracle/middleware_xxx/oracle_common/common/templates/applications/oracle.em_11_1_1_0_0_template.jar", 
            :wls_jrf_template=>"/opt/oracle/middleware_xxx/oracle_common/common/templates/applications/jrf_template_11.1.1.jar", 
            :wls_appl_core_template=>"/opt/oracle/middleware_xxx/oracle_common/common/templates/applications/oracle.applcore.model.stub.11.1.1_template.jar", 
            :wls_wsmpm_template=>"/opt/oracle/middleware_xxx/oracle_common/common/templates/applications/oracle.wsmpm_template_11.1.1.jar", 
            :wls_soa_template=>"/opt/oracle/middleware_xxx/Oracle_SOA1/common/templates/applications/oracle.soa_template_11.1.1.jar", 
            :wls_bpm_template=>"/opt/oracle/middleware_xxx/Oracle_SOA1/common/templates/applications/oracle.bpm_template_11.1.1.jar", 
            :wls_b2b_template=>"", 
            :bpm_enabled=>false, 
            :soa_server_startup_arguments=>"-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Djava.security.egd=file:/dev/./urandom", 
            :bam_cluster=>"", 
            :osb_cluster=>"", 
            :ess_cluster=>"", 
            :soa_cluster=>"", 
            :repository_database_url=>"jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com", 
            :repository_prefix=>"DEV1", 
          }

      )
      expect(chef_run).to create_directory('/opt/oracle/middleware_xxx/user_projects/applications').with(
        recursive: true,
        owner: 'oracle',
        group: 'oinstall'
      )
      expect(chef_run).to execute_fmw_domain_wlst('WLST add soa_suite domain extension').with(
        script_file: '/tmp/soa_suite.py',
        middleware_home_dir: "/opt/oracle/middleware_xxx",
        weblogic_home_dir: "/opt/oracle/middleware_xxx/wlserver_10.3",
        java_home_dir: '/usr/java/jdk1.7.0_75',
        tmp_dir: '/tmp',
        os_user: 'oracle'
      )

    end
  end

  context 'When all attributes are default, 10.3.6, on Windows' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2') do |node|
        node.set['fmw']['java_home_dir']               = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw']['version']                     = '10.3.6'
        node.set['fmw']['middleware_home_dir']         = 'c:\\oracle\\middleware_xxx'
        node.set['fmw']['weblogic_home_dir']           = 'c:\\oracle\\middleware_xxx\\wlserver_10.3'
        node.set['fmw_jdk']['source_file']             = 'c:\\software\\jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file']             = 'c:\\software\\wls1036_generic.jar'
        node.set['fmw_inst']['service_bus_source_file'] = 'c:\\software\\ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip'
        node.set['fmw_inst']['soa_suite_source_file']   = 'c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip'
        node.set['fmw_inst']['soa_suite_source_2_file'] = 'c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip'
        node.set['fmw_rcu']['source_file']              = 'c:\\software\\ofm_rcu_linux_11.1.1.7.0_64_disk1_1of1.zip'
        node.set['fmw_rcu']['jdbc_database_url']        = 'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com'
        node.set['fmw_rcu']['db_database_url']          = '10.10.10.15:1521:soarepos.example.com'
        node.set['fmw_rcu']['rcu_prefix']               = 'DEVXX'
        node.set['fmw_rcu']['databag_key']              = 'entry1'
        node.set['fmw_domain']['domains_dir']           = 'c:\\oracle\\middleware_xxx\\user_projects\\domains'
        node.set['fmw_domain']['apps_dir']              = 'c:\\oracle\\middleware_xxx\\user_projects\\applications'
        node.set['fmw_domain']['databag_key']           = 'entry1'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                                 db_sys_password: 'Welcome01',
                                                                 rcu_component_password: 'Welcome02' })



      stub_data_bag_item("fmw_domains", "entry1").and_return({ id:                         'entry1',
                                                               domain_name:                'base',
                                                               weblogic_user:              'weblogic',
                                                               weblogic_password:          'Welcome01',
                                                               adminserver_name:           'AdminServer',
                                                               adminserver_listen_address: '192.168.2.101',
                                                               adminserver_listen_port:    '7001' ,
                                                               repository_database_url:    "jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com",
                                                               repository_prefix:          "DEV1",
                                                               repository_password:        "Welcome02"
                                                               })
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_domain::domain')
      expect(chef_run).to include_recipe('fmw_inst::soa_suite')

      expect(chef_run).to create_template('C:/temp/soa_suite.py').with(
        source: 'domain/extensions/soa_suite.py',
        variables:  
          {
            :weblogic_home_dir=>"c:/oracle/middleware_xxx/wlserver_10.3", 
            :java_home_dir=>"c:/java/jdk1.7.0_75", 
            :domain_dir=>"c:/oracle/middleware_xxx/user_projects/domains/base", 
            :domain_name=>"base", 
            :app_dir=>"c:/oracle/middleware_xxx/user_projects/applications/base", 
            :adminserver_name=>"AdminServer", 
            :adminserver_listen_address=>"192.168.2.101", 
            :nodemanager_port=>5556,
            :tmp_dir=>"C:/temp", 
            :version=>"10.3.6", 
            :wls_em_template=>"c:\\oracle\\middleware_xxx/oracle_common/common/templates/applications/oracle.em_11_1_1_0_0_template.jar", 
            :wls_jrf_template=>"c:\\oracle\\middleware_xxx/oracle_common/common/templates/applications/jrf_template_11.1.1.jar", 
            :wls_appl_core_template=>"c:\\oracle\\middleware_xxx/oracle_common/common/templates/applications/oracle.applcore.model.stub.11.1.1_template.jar", :wls_wsmpm_template=>"c:\\oracle\\middleware_xxx/oracle_common/common/templates/applications/oracle.wsmpm_template_11.1.1.jar", 
            :wls_soa_template=>"c:\\oracle\\middleware_xxx/Oracle_SOA1/common/templates/applications/oracle.soa_template_11.1.1.jar", 
            :wls_bpm_template=>"c:\\oracle\\middleware_xxx/Oracle_SOA1/common/templates/applications/oracle.bpm_template_11.1.1.jar", 
            :wls_b2b_template=>"", 
            :bpm_enabled=>false, 
            :soa_server_startup_arguments=>"-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m", 
            :bam_cluster=>"", 
            :osb_cluster=>"", 
            :ess_cluster=>"", 
            :soa_cluster=>"", 
            :repository_database_url=>"jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com", 
            :repository_prefix=>"DEV1", 
          }
      )
      expect(chef_run).to create_directory('c:\\oracle\\middleware_xxx\\user_projects\\applications').with(
        recursive: true
      )
      expect(chef_run).to execute_fmw_domain_wlst('WLST add soa_suite domain extension').with(
        script_file: 'C:/temp/soa_suite.py',
        middleware_home_dir: "c:\\oracle\\middleware_xxx",
        weblogic_home_dir: "c:\\oracle\\middleware_xxx\\wlserver_10.3",
        java_home_dir: 'c:\\java\\jdk1.7.0_75',
        tmp_dir: 'C:/temp'
      )

    end
  end
end
