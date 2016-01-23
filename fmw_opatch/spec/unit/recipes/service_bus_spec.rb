#
# Cookbook Name:: fmw_domain
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_opatch::service_bus' do

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /Not supported Operation System, please use it on windows, linux or solaris host/)
    end

  end

  context 'With all attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                 = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                       = '12.1.3'
        node.set['fmw']['middleware_home_dir']           = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']               = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']               = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['service_bus_source_file']  = '/software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /fmw_opatch attributes cannot be empty/)
    end

  end

  context 'Missing soa patch file, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                 = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                       = '12.1.3'
        node.set['fmw']['middleware_home_dir']           = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']               = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']               = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['service_bus_source_file']  = '/software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
        node.set['fmw_opatch']['service_bus_patch_id']   = '20423408'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /source_file parameter cannot be empty/)
    end

  end

  context 'Missing soa patch id, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                   = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                         = '12.1.3'
        node.set['fmw']['middleware_home_dir']             = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']                 = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']                 = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['service_bus_source_file']    = '/software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
        node.set['fmw_opatch']['service_bus_source_file']  = '/software/p20423408_121300_Generic.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /patch_id parameter cannot be empty/)
    end

  end

  context 'With all attributes, 12.1.3, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                   = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                         = '12.1.3'
        node.set['fmw']['middleware_home_dir']             = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']                 = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']                 = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['service_bus_source_file']    = '/software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
        node.set['fmw_opatch']['service_bus_patch_id']     = '20423408'
        node.set['fmw_opatch']['service_bus_source_file']  = '/software/p20423408_121300_Generic.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_inst::service_bus')
      expect(chef_run).to extract_fmw_opatch_fmw_extract('20423408').with(
        source_file:  '/software/p20423408_121300_Generic.zip',
        os_user:      'oracle',
        os_group:     'oinstall',
        tmp_dir:      '/tmp'
      )
      expect(chef_run).to apply_fmw_opatch_opatch('20423408').with(
        patch_id:        '20423408',
        oracle_home_dir: '/opt/oracle/middleware_xxx',
        java_home_dir:   '/usr/java/jdk1.7.0_75',
        orainst_dir:     '/etc',
        os_user:         'oracle',
        os_group:        'oinstall',
        tmp_dir:         '/tmp'
      )
    end

  end

  context 'With all attributes, 10.3.6, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                   = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                         = '10.3.6'
        node.set['fmw']['middleware_home_dir']             = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']                 = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']                 = '/software/wls1036_generic.jar'
        node.set['fmw_inst']['service_bus_source_file']    = '/software/ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip'
        node.set['fmw_opatch']['service_bus_patch_id']     = '20423535'
        node.set['fmw_opatch']['service_bus_source_file']  = '/software/p20423535_111170_Generic.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_inst::service_bus')
      expect(chef_run).to extract_fmw_opatch_fmw_extract('20423535').with(
        source_file:  '/software/p20423535_111170_Generic.zip',
        os_user:      'oracle',
        os_group:     'oinstall',
        tmp_dir:      '/tmp'
      )
      expect(chef_run).to apply_fmw_opatch_opatch('20423535').with(
        patch_id:        '20423535',
        oracle_home_dir: '/opt/oracle/middleware_xxx/Oracle_OSB1',
        java_home_dir:   '/usr/java/jdk1.7.0_75',
        orainst_dir:     '/etc',
        os_user:         'oracle',
        os_group:        'oinstall',
        tmp_dir:         '/tmp'
      )
    end

  end

  context 'With all attributes 12.1.3, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2', step_into: ['fmw_inst_fmw_extract_windows','fmw_inst_fmw_install_windows']) do |node|
        node.set['fmw']['java_home_dir']                   = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw']['version']                         = '12.1.3'
        node.set['fmw']['middleware_home_dir']             = 'c:\\oracle\\middleware_xxx'
        node.set['fmw_jdk']['source_file']                 = 'c:\\software\\jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file']                 = 'c:\\software\\fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['service_bus_source_file']    = 'c:\\software\\fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
        node.set['fmw_opatch']['service_bus_patch_id']     = '20423408'
        node.set['fmw_opatch']['service_bus_source_file']  = 'c:\\software\\p20423408_121300_Generic.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_inst::service_bus')
      expect(chef_run).to extract_fmw_opatch_fmw_extract('20423408').with(
        source_file:  'c:\\software\\p20423408_121300_Generic.zip',
        tmp_dir:      'C:/temp'
      )
      expect(chef_run).to apply_fmw_opatch_opatch('20423408').with(
        patch_id:        '20423408',
        oracle_home_dir: 'c:\\oracle\\middleware_xxx',
        java_home_dir:   'c:\\java\\jdk1.7.0_75',
        tmp_dir:         'C:/temp'
      )
    end

  end

  context 'With all attributes 10.3.6, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2', step_into: ['fmw_inst_fmw_extract_windows','fmw_inst_fmw_install_windows']) do |node|
        node.set['fmw']['java_home_dir']                  = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw']['version']                        = '10.3.6'
        node.set['fmw']['middleware_home_dir']            = 'c:\\oracle\\middleware_xxx'
        node.set['fmw_jdk']['source_file']                = 'c:\\software\\jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file']                = 'c:\\software\\wls1036_generic.jar'
        node.set['fmw_inst']['service_bus_source_file']   = 'c:\\software\\ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip'
        node.set['fmw_opatch']['service_bus_patch_id']    = '20423535'
        node.set['fmw_opatch']['service_bus_source_file'] = 'c:\\software\\p20423535_111170_Generic.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_inst::service_bus')
      expect(chef_run).to extract_fmw_opatch_fmw_extract('20423535').with(
        source_file:  'c:\\software\\p20423535_111170_Generic.zip',
        tmp_dir:      'C:/temp'
      )
      expect(chef_run).to apply_fmw_opatch_opatch('20423535').with(
        patch_id:        '20423535',
        oracle_home_dir: 'c:\\oracle\\middleware_xxx\\Oracle_OSB1',
        java_home_dir:   'c:\\java\\jdk1.7.0_75',
        tmp_dir:         'C:/temp'
      )
    end

  end

end
