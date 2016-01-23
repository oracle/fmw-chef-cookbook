#
# Cookbook Name:: fmw_domain
# Spec:: domain
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_domain::domain' do

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'raises an exception' do
      expect {
        chef_run
      }.to raise_error(RuntimeError, /weblogic_home_dir parameter cannot be empty/)
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
      expect {chef_run}.to raise_error(RuntimeError, /Not supported Operation System, please use it on windows, linux or solaris host/)
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

  context 'All attributes except fmw_domain, 10.3.6, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw']['weblogic_home_dir']            = '/opt/oracle/middleware_xxx/wlserver'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_domain']['databag_key']           = 'entry1'
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

  context 'When all attributes are default, 12.1.3, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw']['weblogic_home_dir']           = '/opt/oracle/middleware_xxx/wlserver'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_domain']['domains_dir']          = '/opt/oracle/middleware_xxx/user_projects/domains'
        node.set['fmw_domain']['databag_key']          = 'entry1'
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
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to create_cookbook_file('/tmp/common.py').with(
        source: 'domain/common.py',
        owner: 'oracle',
        group: 'oinstall'
      )
      expect(chef_run).to create_template('/tmp/domain.py').with(
        source: 'domain/domain.py',
        owner: 'oracle',
        group: 'oinstall',
        variables: { :weblogic_home_dir=>"/opt/oracle/middleware_xxx/wlserver", 
                     :java_home_dir=>"/usr/java/jdk1.7.0_75", 
                     :wls_base_template=>"/opt/oracle/middleware_xxx/wlserver/common/templates/wls/wls.jar",
                     :domain_dir=>"/opt/oracle/middleware_xxx/user_projects/domains/base", 
                     :domain_name=>"base", 
                     :weblogic_user=>"weblogic", 
                     :adminserver_name=>"AdminServer", 
                     :adminserver_startup_arguments=>"-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Djava.security.egd=file:/dev/./urandom", 
                     :adminserver_listen_address=>"192.168.2.101", 
                     :adminserver_listen_port=>"7001", 
                     :nodemanager_port=>5556,
                     :tmp_dir=>"/tmp",
                     :nodemanagers=>[],
                     :servers=>[],
                     :clusters=>[]}

      )
      expect(chef_run).to create_directory('/opt/oracle/middleware_xxx/user_projects/domains').with(
        recursive: true,
        owner: 'oracle',
        group: 'oinstall'
      )
      expect(chef_run).to execute_fmw_domain_wlst('WLST create domain').with(
        script_file: '/tmp/domain.py',
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
        node.set['fmw_domain']['domains_dir']          = 'c:\\oracle\\middleware_xxx\\user_projects\\domains'
        node.set['fmw_domain']['databag_key']          = 'entry1'
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
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to create_cookbook_file('C:/temp/common.py').with(
        source: 'domain/common.py'
      )
      expect(chef_run).to create_template('C:/temp/domain.py').with(
        source: 'domain/domain.py',
        variables: { :weblogic_home_dir=>"c:\\oracle\\middleware_xxx\\wlserver",
                     :java_home_dir=>"c:\\java\\jdk1.7.0_75", 
                     :wls_base_template=>"c:\\oracle\\middleware_xxx\\wlserver/common/templates/wls/wls.jar", 
                     :domain_dir=>"c:\\oracle\\middleware_xxx\\user_projects\\domains/base",
                     :domain_name=>"base",
                     :weblogic_user=>"weblogic", 
                     :adminserver_name=>"AdminServer", 
                     :adminserver_startup_arguments=>"-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m", 
                     :adminserver_listen_address=>"192.168.2.101", 
                     :adminserver_listen_port=>"7001",
                     :nodemanager_port=>5556,
                     :tmp_dir=>"C:/temp",
                     :nodemanagers=>[],
                     :servers=>[],
                     :clusters=>[]
                   }
      )
      expect(chef_run).to create_directory('c:\\oracle\\middleware_xxx\\user_projects\\domains').with(
        recursive: true
      )
      expect(chef_run).to execute_fmw_domain_wlst('WLST create domain').with(
        script_file: 'C:/temp/domain.py',
        middleware_home_dir: 'c:\\oracle\\middleware_xxx',
        weblogic_home_dir: 'c:\\oracle\\middleware_xxx\\wlserver',
        java_home_dir: 'c:\\java\\jdk1.7.0_75',
        tmp_dir: 'C:/temp'
      )
    end
  end

  context 'When all attributes are default, 10.3.6, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '10.3.6'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw']['weblogic_home_dir']           = '/opt/oracle/middleware_xxx/wlserver_10.3'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/wls1036_generic.jar'
        node.set['fmw_domain']['domains_dir']          = '/opt/oracle/middleware_xxx/user_projects/domains'
        node.set['fmw_domain']['databag_key']          = 'entry1'
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
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to create_cookbook_file('/tmp/common.py').with(
        source: 'domain/common.py',
        owner: 'oracle',
        group: 'oinstall'
      )
      expect(chef_run).to create_template('/tmp/domain.py').with(
        source: 'domain/domain.py',
        owner: 'oracle',
        group: 'oinstall',
        variables: {
          :weblogic_home_dir=>"/opt/oracle/middleware_xxx/wlserver_10.3",
          :java_home_dir=>"/usr/java/jdk1.7.0_75",
          :wls_base_template=>"/opt/oracle/middleware_xxx/wlserver_10.3/common/templates/domains/wls.jar",
          :domain_dir=>"/opt/oracle/middleware_xxx/user_projects/domains/base",
          :domain_name=>"base",
          :weblogic_user=>"weblogic",
          :adminserver_name=>"AdminServer",
          :adminserver_startup_arguments=>"-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Djava.security.egd=file:/dev/./urandom",
          :adminserver_listen_address=>"192.168.2.101",
          :adminserver_listen_port=>"7001",
          :nodemanager_port=>5556,
          :tmp_dir=>"/tmp",
          :nodemanagers=>[],
          :servers=>[],
          :clusters=>[]
        }
      )
      expect(chef_run).to create_directory('/opt/oracle/middleware_xxx/user_projects/domains').with(
        recursive: true,
        owner: 'oracle',
        group: 'oinstall'
      )
      expect(chef_run).to execute_fmw_domain_wlst('WLST create domain').with(
        script_file: '/tmp/domain.py',
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
        node.set['fmw_domain']['domains_dir']          = 'c:\\oracle\\middleware_xxx\\user_projects\\domains'
        node.set['fmw_domain']['databag_key']          = 'entry1'
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
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to create_cookbook_file('C:/temp/common.py').with(
        source: 'domain/common.py'
      )
      expect(chef_run).to create_template('C:/temp/domain.py').with(
        source: 'domain/domain.py',
        variables: { :weblogic_home_dir=>"c:\\oracle\\middleware_xxx\\wlserver_10.3",
                     :java_home_dir=>"c:\\java\\jdk1.7.0_75", 
                     :wls_base_template=>"c:\\oracle\\middleware_xxx\\wlserver_10.3/common/templates/domains/wls.jar", 
                     :domain_dir=>"c:\\oracle\\middleware_xxx\\user_projects\\domains/base",
                     :domain_name=>"base",
                     :weblogic_user=>"weblogic", 
                     :adminserver_name=>"AdminServer", 
                     :adminserver_startup_arguments=>"-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m", 
                     :adminserver_listen_address=>"192.168.2.101", 
                     :adminserver_listen_port=>"7001",
                     :nodemanager_port=>5556,
                     :tmp_dir=>"C:/temp",
                     :nodemanagers=>[],
                     :servers=>[],
                     :clusters=>[]
                   }
      )
      expect(chef_run).to create_directory('c:\\oracle\\middleware_xxx\\user_projects\\domains').with(
        recursive: true
      )
      expect(chef_run).to execute_fmw_domain_wlst('WLST create domain').with(
        script_file: 'C:/temp/domain.py',
        middleware_home_dir: 'c:\\oracle\\middleware_xxx',
        weblogic_home_dir: 'c:\\oracle\\middleware_xxx\\wlserver_10.3',
        java_home_dir: 'c:\\java\\jdk1.7.0_75',
        tmp_dir: 'C:/temp'
      )
    end
  end



end
