#
# Cookbook Name:: fmw_rcu
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_rcu::soa_suite' do

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'raises an exception' do
      expect {
        chef_run
      }.to raise_error(RuntimeError, /databag_key parameter cannot be empty/)
    end

  end

  context 'When all attributes are default 2, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new() do |node|
        node.set['fmw_rcu']['databag_key']             = 'entry1'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                             db_sys_password: 'Welcome01',
                                                             rcu_component_password: 'Welcome02' })
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /Not supported Operation System, please use it on windows, linux or solaris host/)
    end

  end

  context 'All attributes except fmw_rcu, 12.1.3, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = '/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
        node.set['fmw_rcu']['databag_key']             = 'entry1'
      end


      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                             db_sys_password: 'Welcome01',
                                                             rcu_component_password: 'Welcome02' })
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /oracle_home_dir parameter cannot be empty/)
    end

  end

  context 'All attributes except fmw_rcu, 10.3.6, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_rcu']['databag_key']              = 'entry1'
      end


      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                             db_sys_password: 'Welcome01',
                                                             rcu_component_password: 'Welcome02' })
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /source_file parameter cannot be empty/)
    end

  end

  context 'When all attributes are default, 12.1.3, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = '/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
        node.set['fmw_rcu']['oracle_home_dir']         = '/opt/oracle/middleware_xxx/oracle_common'
        node.set['fmw_rcu']['jdbc_database_url']       = 'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com'
        node.set['fmw_rcu']['db_database_url']         = '10.10.10.15:1521:soarepos.example.com'
        node.set['fmw_rcu']['rcu_prefix']              = 'DEVXX'
        node.set['fmw_rcu']['databag_key']             = 'entry1'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                             db_sys_password: 'Welcome01',
                                                             rcu_component_password: 'Welcome02' })
    end

    it 'converges successfully' do
      # expect(chef_run).to include_recipe('fmw_inst::soa_suite')
      expect(chef_run).to create_fmw_rcu_repository('DEVXX').with(
        java_home_dir:          '/usr/java/jdk1.7.0_75',
        oracle_home_dir:        '/opt/oracle/middleware_xxx/oracle_common',
        middleware_home_dir:    '/opt/oracle/middleware_xxx',
        version:                '12.1.3',
        jdbc_connect_url:       'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com',
        db_connect_url:         '10.10.10.15:1521:soarepos.example.com',
        db_connect_user:        'sys',
        db_connect_password:    'Welcome01',
        rcu_prefix:             'DEVXX',
        rcu_components:         ["MDS", "IAU", "IAU_APPEND", "IAU_VIEWER", "OPSS", "WLS", "UCSUMS", "ESS", "SOAINFRA"],
        rcu_component_password: 'Welcome02',
        os_user:                'oracle',
        os_group:               'oinstall',
        tmp_dir:                '/tmp'
      )

      expect(chef_run).to create_cookbook_file('/tmp/checkrcu.py').with(
        source: 'checkrcu.py',
        owner: 'oracle',
        group: 'oinstall',
        mode: 0775
      )
    end

  end

  context 'When all attributes are default, 12.1.3, on Solaris' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'solaris2', version: '5.11') do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = '/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
        node.set['fmw_rcu']['oracle_home_dir']         = '/opt/oracle/middleware_xxx/oracle_common'
        node.set['fmw_rcu']['jdbc_database_url']       = 'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com'
        node.set['fmw_rcu']['db_database_url']         = '10.10.10.15:1521:soarepos.example.com'
        node.set['fmw_rcu']['rcu_prefix']              = 'DEVXX'
        node.set['fmw_rcu']['databag_key']             = 'entry1'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                             db_sys_password: 'Welcome01',
                                                             rcu_component_password: 'Welcome02' })
    end

    it 'converges successfully' do
      # expect(chef_run).to include_recipe('fmw_inst::soa_suite')
      expect(chef_run).to create_fmw_rcu_repository('DEVXX').with(
        java_home_dir:          '/usr/java/jdk1.7.0_75',
        oracle_home_dir:        '/opt/oracle/middleware_xxx/oracle_common',
        middleware_home_dir:    '/opt/oracle/middleware_xxx',
        version:                '12.1.3',
        jdbc_connect_url:       'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com',
        db_connect_url:         '10.10.10.15:1521:soarepos.example.com',
        db_connect_user:        'sys',
        db_connect_password:    'Welcome01',
        rcu_prefix:             'DEVXX',
        rcu_components:         ["MDS", "IAU", "IAU_APPEND", "IAU_VIEWER", "OPSS", "WLS", "UCSUMS", "ESS", "SOAINFRA"],
        rcu_component_password: 'Welcome02',
        os_user:                'oracle',
        os_group:               'oinstall',
        tmp_dir:                '/var/tmp'
      )
      expect(chef_run).to create_cookbook_file('/var/tmp/checkrcu.py').with(
        source: 'checkrcu.py',
        owner: 'oracle',
        group: 'oinstall',
        mode: 0775
      )
    end

  end

  context 'When all attributes are default, 12.1.3, on Windows' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2') do |node|
        node.set['fmw']['java_home_dir']               = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = 'c:\\oracle\\middleware_xxx'
        node.set['fmw_jdk']['source_file']             = 'c:\\software\\jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file']             = 'c:\\software\\fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = 'c:\\software\\fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
        node.set['fmw_rcu']['oracle_home_dir']         = 'c:\\oracle\\middleware_xxx\\oracle_common'
        node.set['fmw_rcu']['jdbc_database_url']       = 'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com'
        node.set['fmw_rcu']['db_database_url']         = '10.10.10.15:1521:soarepos.example.com'
        node.set['fmw_rcu']['rcu_prefix']              = 'DEVXX'
        node.set['fmw_rcu']['databag_key']             = 'entry1'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                             db_sys_password: 'Welcome01',
                                                             rcu_component_password: 'Welcome02' })
    end

    it 'converges successfully' do
      # expect(chef_run).to include_recipe('fmw_inst::soa_suite')
      expect(chef_run).to create_fmw_rcu_repository('DEVXX').with(
        java_home_dir:          'c:\\java\\jdk1.7.0_75',
        oracle_home_dir:        'c:\\oracle\\middleware_xxx\\oracle_common',
        middleware_home_dir:    'c:\\oracle\\middleware_xxx',
        version:                '12.1.3',
        jdbc_connect_url:       'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com',
        db_connect_url:         '10.10.10.15:1521:soarepos.example.com',
        db_connect_user:        'sys',
        db_connect_password:    'Welcome01',
        rcu_prefix:             'DEVXX',
        rcu_components:         ["MDS", "IAU", "IAU_APPEND", "IAU_VIEWER", "OPSS", "WLS", "UCSUMS", "ESS", "SOAINFRA"],
        rcu_component_password: 'Welcome02',
        tmp_dir:                'C:/temp'
      )
      expect(chef_run).to create_cookbook_file('C:/temp/checkrcu.py').with(
        source: 'checkrcu.py'
      )

    end

  end

  context 'When all attributes are default, 10.3.6, on CentOS' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_rcu']['source_file']              = '/software/ofm_rcu_linux_11.1.1.7.0_64_disk1_1of1.zip'
        node.set['fmw_rcu']['jdbc_database_url']        = 'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com'
        node.set['fmw_rcu']['db_database_url']          = '10.10.10.15:1521:soarepos.example.com'
        node.set['fmw_rcu']['rcu_prefix']               = 'DEVXX'
        node.set['fmw_rcu']['databag_key']              = 'entry1'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                             db_sys_password: 'Welcome01',
                                                             rcu_component_password: 'Welcome02' })
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to create_fmw_rcu_repository('DEVXX').with(
        java_home_dir:          '/usr/java/jdk1.7.0_75',
        oracle_home_dir:        '/tmp/rcu/rcuHome',
        middleware_home_dir:    '/opt/oracle/middleware_xxx',
        version:                '10.3.6',
        jdbc_connect_url:       'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com',
        db_connect_url:         '10.10.10.15:1521:soarepos.example.com',
        db_connect_user:        'sys',
        db_connect_password:    'Welcome01',
        rcu_prefix:             'DEVXX',
        rcu_components:         ["SOAINFRA", "ORASDPM", "MDS", "OPSS", "BAM"],
        rcu_component_password: 'Welcome02',
        os_user:                'oracle',
        os_group:               'oinstall',
        tmp_dir:                '/tmp'
      )
      expect(chef_run).to create_cookbook_file('/tmp/checkrcu.py').with(
        source: 'checkrcu.py',
        owner: 'oracle',
        group: 'oinstall',
        mode: 0775
      )
      expect(chef_run).to run_execute('extract rcu file').with(
        command: 'unzip -o /software/ofm_rcu_linux_11.1.1.7.0_64_disk1_1of1.zip -d /tmp/rcu',
        cwd: "/tmp",
        user: 'oracle',
        group: 'oinstall',
        creates: "/tmp/rcu/rcuHome"
      )

    end

  end

  context 'When all attributes are default, 10.3.6, on Solaris' do 

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'solaris2', version: '5.11') do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_rcu']['source_file']              = '/software/ofm_rcu_linux_11.1.1.7.0_64_disk1_1of1.zip'
        node.set['fmw_rcu']['jdbc_database_url']        = 'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com'
        node.set['fmw_rcu']['db_database_url']          = '10.10.10.15:1521:soarepos.example.com'
        node.set['fmw_rcu']['databag_key']              = 'entry1'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                             db_sys_password: 'Welcome01',
                                                             rcu_component_password: 'Welcome02' })
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /there is no rcu installer supported for solaris/)
    end

  end


  context 'When all attributes are default, 10.3.6, on Windows' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2') do |node|
        node.set['fmw']['java_home_dir']                = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = 'c:\\oracle\\middleware_xxx'
        node.set['fmw_jdk']['source_file']              = 'c:\\software\\jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file']              = 'c:\\software\\wls1036_generic.jar'
        node.set['fmw_rcu']['source_file']              = 'c:\\software\\ofm_rcu_win_11.1.1.7.0_32_disk1_1of1.zip'
        node.set['fmw_rcu']['jdbc_database_url']        = 'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com'
        node.set['fmw_rcu']['db_database_url']          = '10.10.10.15:1521:soarepos.example.com'
        node.set['fmw_rcu']['rcu_prefix']               = 'DEVXX'
        node.set['fmw_rcu']['databag_key']              = 'entry1'
      end

      runner.converge(described_recipe)
    end

    before do
      stub_data_bag_item("fmw_databases", "entry1").and_return({ id: 'entry1',
                                                             db_sys_password: 'Welcome01',
                                                             rcu_component_password: 'Welcome02' })
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to create_fmw_rcu_repository('DEVXX').with(
        java_home_dir:          'c:\\java\\jdk1.7.0_75',
        oracle_home_dir:        'C:/temp\\rcu\\rcuHome',
        middleware_home_dir:    'c:\\oracle\\middleware_xxx',
        version:                '10.3.6',
        jdbc_connect_url:       'jdbc:oracle:thin:@10.10.10.15:1521/soarepos.example.com',
        db_connect_url:         '10.10.10.15:1521:soarepos.example.com',
        db_connect_user:        'sys',
        db_connect_password:    'Welcome01',
        rcu_prefix:             'DEVXX',
        rcu_components:         ["SOAINFRA", "ORASDPM", "MDS", "OPSS", "BAM"],
        rcu_component_password: 'Welcome02',
        tmp_dir:                'C:/temp'
      )
      expect(chef_run).to create_cookbook_file('C:/temp/checkrcu.py').with(
        source: 'checkrcu.py'
      )
      expect(chef_run).to run_execute('extract rcu file').with(
        command: 'c:\\oracle\\middleware_xxx\\wlserver_10.3\\server\\adr\\unzip.exe -o c:\\software\\ofm_rcu_win_11.1.1.7.0_32_disk1_1of1.zip -d C:/temp\\rcu',
        cwd: "C:/temp",
        creates: "C:/temp\\rcu\\rcuHome"
      )


    end

  end

end
