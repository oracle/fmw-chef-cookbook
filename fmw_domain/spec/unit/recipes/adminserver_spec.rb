#
# Cookbook Name:: fmw_domain
# Spec:: adminserver
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_domain::adminserver' do

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

    it 'converges with an error' do
      expect {chef_run}.to raise_error( Chef::Exceptions::ValidationFailed, /Required argument domain_name is missing/)
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
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
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
      expect(chef_run).to include_recipe('fmw_domain::nodemanager')
      expect(chef_run).to start_fmw_domain_adminserver('adminserver').with(
        domain_dir: '/opt/oracle/middleware_xxx/user_projects/domains/base',
        domain_name: 'base',
        adminserver_name: 'AdminServer',
        weblogic_home_dir: '/opt/oracle/middleware_xxx/wlserver',
        os_user: 'oracle',
        java_home_dir: '/usr/java/jdk1.7.0_75',
        weblogic_user: 'weblogic',
        weblogic_password: 'Welcome01',
        nodemanager_listen_address: '10.10.10.10',
        nodemanager_port: 5556,
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
      expect(chef_run).to include_recipe('fmw_domain::nodemanager')
      expect(chef_run).to start_fmw_domain_adminserver('adminserver').with(
        domain_dir: 'c:\\oracle\\middleware_xxx\\user_projects\\domains/base',
        domain_name: 'base',
        adminserver_name: 'AdminServer',
        weblogic_home_dir: 'c:\\oracle\\middleware_xxx\\wlserver',
        java_home_dir: 'c:\\java\\jdk1.7.0_75',
        weblogic_user: 'weblogic',
        weblogic_password: 'Welcome01',
        nodemanager_listen_address: '10.10.10.10',
        nodemanager_port: 5556,
      )


    end
  end

 

end
