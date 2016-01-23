#
# Cookbook Name:: fmw_domain
# Spec:: nodemanager
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_domain::nodemanager' do

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'raises an exception' do
      expect {
        chef_run
      }.to raise_error(RuntimeError, /nodemanager_listen_address parameter cannot be empty/)
    end

  end

  context 'When all attributes are default 2, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new() do |node|
        node.set['fmw']['weblogic_home_dir']       = '/opt/oracle/middleware_xxx/wlserver'
        node.set['fmw_domain']['databag_key']      = 'entry1'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_domain", "entry1").and_return({ id: 'entry1' })
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /nodemanager_listen_address parameter cannot be empty/)
    end

  end

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new() do |node|
        node.set['fmw_domain']['nodemanager_listen_address']  = '10.10.10.10'
      end
      runner.converge(described_recipe)
    end

    it 'raises an exception' do
      expect {
        chef_run
      }.to raise_error(RuntimeError, /databag_key parameter cannot be empty/)
    end

  end


  context 'All attributes except fmw_domain, 12.1.3, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                      = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                            = '12.1.3'
        node.set['fmw']['middleware_home_dir']                = '/opt/oracle/middleware_xxx'
        node.set['fmw']['weblogic_home_dir']                  = '/opt/oracle/middleware_xxx/wlserver'
        node.set['fmw_jdk']['source_file']                    = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']                    = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_domain']['databag_key']                 = 'entry1'
        node.set['fmw_domain']['nodemanager_listen_address']  = '10.10.10.10'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_domains", "entry1").and_return({ id: 'entry1' })
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end

  context 'All attributes except fmw_domain, 12.1.3, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw']['weblogic_home_dir']           = '/opt/oracle/middleware_xxx/wlserver'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_domain']['databag_key']          = 'entry1'
        node.set['fmw_domain']['nodemanager_listen_address']  = '10.10.10.10'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_domains", "entry1").and_return({ id:                         'entry1',
                                                               domain_name:                'base',
                                                               weblogic_user:              'weblogic',
                                                               weblogic_password:          'Welcome01',
                                                               adminserver_name:           'AdminServer',
                                                               adminserver_listen_address: '192.168.2.101',
                                                               adminserver_listen_port:    '7001' })
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end


  context 'When all attributes are default, 12.1.3, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6' , step_into: ['fmw_domain_nodemanager_service_redhat']) do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw']['weblogic_home_dir']           = '/opt/oracle/middleware_xxx/wlserver'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_domain']['domains_dir']          = '/opt/oracle/middleware_xxx/user_projects/domains'
        node.set['fmw_domain']['databag_key']          = 'entry1'
        node.set['fmw_domain']['nodemanager_listen_address']  = '10.10.10.10'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_command("chkconfig | /bin/grep 'nodemanager_base'").and_return(false)
      stub_data_bag_item("fmw_domains", "entry1").and_return({ id:                         'entry1',
                                                               domain_name:                'base',
                                                               weblogic_user:              'weblogic',
                                                               weblogic_password:          'Welcome01',
                                                               adminserver_name:           'AdminServer',
                                                               adminserver_listen_address: '192.168.2.101',
                                                               adminserver_listen_port:    '7001' })
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_domain::domain')
      expect(chef_run).to create_template('/opt/oracle/middleware_xxx/user_projects/domains/base/nodemanager/nodemanager.properties').with(
        source: 'nodemanager/nodemanager.properties_12c',
        owner: 'oracle',
        group: 'oinstall',
        variables: {
          :weblogic_home_dir=>"/opt/oracle/middleware_xxx/wlserver",
          :java_home_dir=>"/usr/java/jdk1.7.0_75",
          :nodemanager_log_dir=>"/opt/oracle/middleware_xxx/user_projects/domains/base/nodemanager/nodemanager.log",
          :domain_dir=>"/opt/oracle/middleware_xxx/user_projects/domains/base",
          :nodemanager_address=>"10.10.10.10",
          :nodemanager_port=>5556,
          :nodemanager_secure_listener=>true,
          :platform_family=>"rhel",
          :version=>"12.1.3"}
      )
      expect(chef_run).to create_template('/etc/init.d/nodemanager_base').with(
        source: 'nodemanager/nodemanager',
        variables:  {
          :platform_family=>"rhel",
          :nodemanager_lock_file=>"/opt/oracle/middleware_xxx/user_projects/domains/base/nodemanager/nodemanager.log.lck",
          :nodemanager_bin_path=>"/opt/oracle/middleware_xxx/user_projects/domains/base/bin",
          :nodemanager_check=>"/opt/oracle/middleware_xxx/user_projects/domains/base",
          :os_user=>"oracle"
        }
      )
      expect(chef_run).to configure_fmw_domain_nodemanager_service('nodemanager_base').with(
        user_home_dir: '/home',
        os_user: 'oracle'
      )
      expect(chef_run).to run_execute('chkconfig nodemanager_base').with(
        command: 'chkconfig --add nodemanager_base'
      )
      expect(chef_run).to start_service('nodemanager_base')

    end
  end

 context 'When all attributes are default, 12.1.3, on CentOS 7' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '7.0' , step_into: ['fmw_domain_nodemanager_service_redhat_7']) do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw']['weblogic_home_dir']           = '/opt/oracle/middleware_xxx/wlserver'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_domain']['domains_dir']          = '/opt/oracle/middleware_xxx/user_projects/domains'
        node.set['fmw_domain']['databag_key']          = 'entry1'
        node.set['fmw_domain']['nodemanager_listen_address']  = '10.10.10.10'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_domains", "entry1").and_return({ id:                         'entry1',
                                                               domain_name:                'base',
                                                               weblogic_user:              'weblogic',
                                                               weblogic_password:          'Welcome01',
                                                               adminserver_name:           'AdminServer',
                                                               adminserver_listen_address: '192.168.2.101',
                                                               adminserver_listen_port:    '7001' })
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_domain::domain')
      expect(chef_run).to create_template('/opt/oracle/middleware_xxx/user_projects/domains/base/nodemanager/nodemanager.properties').with(
        source: 'nodemanager/nodemanager.properties_12c',
        owner: 'oracle',
        group: 'oinstall',
        variables: {
          :weblogic_home_dir=>"/opt/oracle/middleware_xxx/wlserver",
          :java_home_dir=>"/usr/java/jdk1.7.0_75",
          :nodemanager_log_dir=>"/opt/oracle/middleware_xxx/user_projects/domains/base/nodemanager/nodemanager.log",
          :domain_dir=>"/opt/oracle/middleware_xxx/user_projects/domains/base",
          :nodemanager_address=>"10.10.10.10",
          :nodemanager_port=>5556,
          :nodemanager_secure_listener=>true,
          :platform_family=>"rhel",
          :version=>"12.1.3"}
      )
      expect(chef_run).to create_template('/home/oracle/nodemanager_base').with(
        source: 'nodemanager/nodemanager',
        variables: {
          :platform_family=>"rhel",
          :nodemanager_lock_file=>"/opt/oracle/middleware_xxx/user_projects/domains/base/nodemanager/nodemanager.log.lck",
          :nodemanager_bin_path=>"/opt/oracle/middleware_xxx/user_projects/domains/base/bin",
          :nodemanager_check=>"/opt/oracle/middleware_xxx/user_projects/domains/base",
          :os_user=>"oracle"}
      )
      expect(chef_run).to configure_fmw_domain_nodemanager_service('nodemanager_base').with(
        user_home_dir: '/home',
        os_user: 'oracle'
      )

      resource = chef_run.execute('systemctl-daemon-reload')
      expect(resource).to do_nothing

      resource2 = chef_run.execute('systemctl-enable')
      expect(resource2).to do_nothing

      resource3 = chef_run.template('/lib/systemd/system/nodemanager_base.service')
      expect(resource3).to notify('execute[systemctl-daemon-reload]').to(:run).immediately
      expect(resource3).to notify('execute[systemctl-enable]').to(:run).immediately
      expect(resource3).to notify('service[nodemanager_base.service]').to(:enable).immediately
      expect(resource3).to notify('service[nodemanager_base.service]').to(:restart).immediately

      expect(chef_run).to start_service('nodemanager_base.service')

      expect(chef_run).to create_template('/lib/systemd/system/nodemanager_base.service').with(
        source: 'nodemanager/systemd',
        variables: {
          :script_name=>"nodemanager_base",
          :user_home_dir=>"/home",
          :os_user=>"oracle"}
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
        node.set['fmw_domain']['domains_dir']          = 'c:\\oracle\\middleware_xxx\\user_projects\\domains'
        node.set['fmw_domain']['databag_key']          = 'entry1'
        node.set['fmw_domain']['nodemanager_listen_address']  = '10.10.10.10'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_domains", "entry1").and_return({ id:                         'entry1',
                                                               domain_name:                'base',
                                                               weblogic_user:              'weblogic',
                                                               weblogic_password:          'Welcome01',
                                                               adminserver_name:           'AdminServer',
                                                               adminserver_listen_address: '192.168.2.101',
                                                               adminserver_listen_port:    '7001' })
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_domain::domain')
      expect(chef_run).to create_template('c:\\oracle\\middleware_xxx\\user_projects\\domains/base/nodemanager/nodemanager.properties').with(
        source: 'nodemanager/nodemanager.properties_12c',
        variables: {
          :weblogic_home_dir=>"c:/oracle/middleware_xxx/wlserver",
          :java_home_dir=>"c:/java/jdk1.7.0_75",
          :nodemanager_log_dir=>"c:/oracle/middleware_xxx/user_projects/domains/base/nodemanager/nodemanager.log",
          :domain_dir=>"c:/oracle/middleware_xxx/user_projects/domains/base",
          :nodemanager_address=>"10.10.10.10",
          :nodemanager_port=>5556,
          :nodemanager_secure_listener=>true,
          :platform_family=>"windows",
          :version=>"12.1.3"}
      )
      expect(chef_run).to configure_fmw_domain_nodemanager_service('nodemanager_base').with(
        domain_dir: 'c:\\oracle\\middleware_xxx\\user_projects\\domains/base',
        domain_name: 'base',
        version: '12.1.3',
        middleware_home_dir: 'c:\\oracle\\middleware_xxx',
        bin_dir: 'c:\\oracle\\middleware_xxx\\user_projects\\domains/base/bin',
        java_home_dir: 'c:\\java\\jdk1.7.0_75'
      )
    end
  end

  context 'When all attributes are default, 10.3.6, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6', step_into: ['fmw_domain_nodemanager_service_redhat']) do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '10.3.6'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw']['weblogic_home_dir']           = '/opt/oracle/middleware_xxx/wlserver_10.3'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/wls1036_generic.jar'
        node.set['fmw_domain']['domains_dir']          = '/opt/oracle/middleware_xxx/user_projects/domains'
        node.set['fmw_domain']['databag_key']          = 'entry1'
        node.set['fmw_domain']['nodemanager_listen_address']  = '10.10.10.10'
      end


      runner.converge(described_recipe)
    end

    before do
      stub_command("chkconfig | /bin/grep 'nodemanager_11g'").and_return(false)
      stub_data_bag_item("fmw_domains", "entry1").and_return({ id:                         'entry1',
                                                               domain_name:                'base',
                                                               weblogic_user:              'weblogic',
                                                               weblogic_password:          'Welcome01',
                                                               adminserver_name:           'AdminServer',
                                                               adminserver_listen_address: '192.168.2.101',
                                                               adminserver_listen_port:    '7001' })
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_domain::domain')
      expect(chef_run).to create_template('/opt/oracle/middleware_xxx/wlserver_10.3/common/nodemanager/nodemanager.properties').with(
        source: 'nodemanager/nodemanager.properties_11g',
        owner: 'oracle',
        group: 'oinstall',
        variables: {
          :weblogic_home_dir=>"/opt/oracle/middleware_xxx/wlserver_10.3",
          :java_home_dir=>"/usr/java/jdk1.7.0_75",
          :nodemanager_log_dir=>"/opt/oracle/middleware_xxx/wlserver_10.3/common/nodemanager/nodemanager.log",
          :domain_dir=>"/opt/oracle/middleware_xxx/user_projects/domains/base",
          :nodemanager_address=>"10.10.10.10",
          :nodemanager_port=>5556,
          :nodemanager_secure_listener=>true,
          :platform_family=>"rhel",
          :version=>"10.3.6"}
      )
      expect(chef_run).to create_template('/etc/init.d/nodemanager_11g').with(
        source: 'nodemanager/nodemanager',
        variables:  {
          :platform_family=>"rhel",
          :nodemanager_lock_file=>"/opt/oracle/middleware_xxx/wlserver_10.3/common/nodemanager/nodemanager.log.lck",
          :nodemanager_bin_path=>"/opt/oracle/middleware_xxx/wlserver_10.3/server/bin",
          :nodemanager_check=>"/opt/oracle/middleware_xxx/wlserver_10.3",
          :os_user=>"oracle"}
      )
      expect(chef_run).to configure_fmw_domain_nodemanager_service('nodemanager_11g').with(
        user_home_dir: '/home',
        os_user: 'oracle'
      )
      expect(chef_run).to run_execute('chkconfig nodemanager_11g').with(
        command: 'chkconfig --add nodemanager_11g'
      )
      expect(chef_run).to start_service('nodemanager_11g')

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
        node.set['fmw_domain']['domains_dir']          = 'c:\\oracle\\middleware_xxx\\user_projects\\domains'
        node.set['fmw_domain']['databag_key']          = 'entry1'
        node.set['fmw_domain']['nodemanager_listen_address']  = '10.10.10.10'
      end


      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_domains", "entry1").and_return({ id:                         'entry1',
                                                               domain_name:                'base',
                                                               weblogic_user:              'weblogic',
                                                               weblogic_password:          'Welcome01',
                                                               adminserver_name:           'AdminServer',
                                                               adminserver_listen_address: '192.168.2.101',
                                                               adminserver_listen_port:    '7001' })
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_domain::domain')
      expect(chef_run).to create_template('c:\oracle\middleware_xxx\wlserver_10.3/common/nodemanager/nodemanager.properties').with(
        source: 'nodemanager/nodemanager.properties_11g',
        variables: {
          :weblogic_home_dir=>"c:/oracle/middleware_xxx/wlserver_10.3",
          :java_home_dir=>"c:/java/jdk1.7.0_75",
          :nodemanager_log_dir=>"c:/oracle/middleware_xxx/wlserver_10.3/common/nodemanager/nodemanager.log",
          :domain_dir=>"c:/oracle/middleware_xxx/user_projects/domains/base",
          :nodemanager_address=>"10.10.10.10",
          :nodemanager_port=>5556,
          :nodemanager_secure_listener=>true,
          :platform_family=>"windows",
          :version=>"10.3.6"}
      )
      expect(chef_run).to configure_fmw_domain_nodemanager_service('nodemanager_11g').with(
        domain_dir: 'c:\\oracle\\middleware_xxx\\user_projects\\domains/base',
        domain_name: 'base',
        version: '10.3.6',
        middleware_home_dir: 'c:\\oracle\\middleware_xxx',
        bin_dir: 'c:\\oracle\\middleware_xxx\\wlserver_10.3/server/bin',
        java_home_dir: 'c:\\java\\jdk1.7.0_75'
      )

    end
  end



end
