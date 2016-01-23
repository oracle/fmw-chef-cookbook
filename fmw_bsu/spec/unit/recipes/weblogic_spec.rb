#
# Cookbook Name:: fmw_bsu
# Spec:: weblogic
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_bsu::weblogic' do

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end

  context 'With only jdk attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.7.0_75'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-7u75-linux-x64.tar.gz'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end

  context 'With jdk and wls attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']     = '/usr/java/jdk1.7.0_75'
        node.set['fmw_jdk']['source_file']   = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']   = '/software/wls1036_generic.jar'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end


  context 'With all attributes except bsu, 10.3.6, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /fmw_bsu attributes cannot be empty/)
    end

  end

  context 'With all attributes with only bsu patch id, 10.3.6, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_bsu']['patch_id']                 = 'YUIS'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /source_file parameter cannot be empty/)
    end

  end


  context 'With all attributes 10.3.6, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6', step_into: ['fmw_inst_fmw_extract','fmw_inst_fmw_install_linux']) do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_bsu']['patch_id']                 = 'YUIS'
        node.set['fmw_bsu']['source_file']              = '/software/p20181997_1036_Generic.zip'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command("grep 'MEM_ARGS=\"-Xms512m -Xmx752m -XX:-UseGCOverheadLimit\"' /opt/oracle/middleware_xxx/utils/bsu/bsu.sh").and_return(false)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')

      expect(chef_run).to create_directory('/opt/oracle/middleware_xxx/utils/bsu/cache_dir').with(
        recursive: true,
        owner: 'oracle',
        group: 'oinstall',
        mode:  '0755'
      )

      expect(chef_run).to run_execute('extract YUIS').with(
      	command: 'unzip -o /software/p20181997_1036_Generic.zip -d /opt/oracle/middleware_xxx/utils/bsu/cache_dir',
      	creates: '/opt/oracle/middleware_xxx/utils/bsu/cache_dir/YUIS.jar',
        cwd:     '/tmp',
        user:    'oracle',
        group:   'oinstall'
      )

      expect(chef_run).to run_execute('patch bsu.sh').with(
        user:    'oracle',
        group:   'oinstall'
      )

      expect(chef_run).to create_file('/opt/oracle/middleware_xxx/utils/bsu/bsu.sh').with(
        owner: 'oracle',
        group: 'oinstall',
        mode:  '0755'
      )

      expect(chef_run).to install_fmw_bsu_bsu('YUIS').with(
        patch_id:            'YUIS',
        middleware_home_dir: '/opt/oracle/middleware_xxx',
        os_user:             'oracle'
      )
    end

  end


  context 'With all attributes 10.3.6, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2') do |node|
        node.set['fmw']['java_home_dir']                = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = 'c:\\oracle\\middleware_xxx'
        node.set['fmw_jdk']['source_file']              = 'c:\\software\\jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file']              = 'c:\\software\\wls1036_generic.jar'
        node.set['fmw_bsu']['patch_id']                 = 'YUIS'
        node.set['fmw_bsu']['source_file']              = 'c:\\software\\p20181997_1036_Generic.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')

      expect(chef_run).to create_directory('c:\oracle\middleware_xxx\utils\bsu\cache_dir').with(
        recursive: true
      )

      expect(chef_run).to run_execute('extract YUIS').with(
      	command: 'c:\\oracle\\middleware_xxx\\wlserver_10.3\\server\\adr\\unzip.exe -o c:\\software\\p20181997_1036_Generic.zip -d c:\\oracle\\middleware_xxx/utils/bsu/cache_dir',
      	creates: 'c:\\oracle\\middleware_xxx/utils/bsu/cache_dir/YUIS.jar'
      )

      expect(chef_run).to install_fmw_bsu_bsu('YUIS').with(
        patch_id:            'YUIS',
        middleware_home_dir: 'c:\\oracle\\middleware_xxx'
      )
    end

  end


  context 'With all attributes 10.3.6, on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11') do |node|
        node.set['fmw']['java_home_dir']                = '/usr/jdk/instances/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-solaris-i586.tar.gz'
        node.set['fmw_jdk']['source_x64_file']          = '/software/jdk-7u75-solaris-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_bsu']['patch_id']                 = 'YUIS'
        node.set['fmw_bsu']['source_file']              = '/software/p20181997_1036_Generic.zip'
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command("grep 'MEM_ARGS=\"-Xms512m -Xmx752m -XX:-UseGCOverheadLimit\"' /opt/oracle/middleware_xxx/utils/bsu/bsu.sh").and_return(false)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')

      expect(chef_run).to create_directory('/opt/oracle/middleware_xxx/utils/bsu/cache_dir').with(
        recursive: true,
        owner: 'oracle',
        group: 'oinstall',
        mode:  '0755'
      )

      expect(chef_run).to run_execute('extract YUIS').with(
      	command: 'unzip -o /software/p20181997_1036_Generic.zip -d /opt/oracle/middleware_xxx/utils/bsu/cache_dir',
      	creates: '/opt/oracle/middleware_xxx/utils/bsu/cache_dir/YUIS.jar',
        cwd:     '/var/tmp',
        user:    'oracle',
        group:   'oinstall'
      )

      expect(chef_run).to run_execute('patch bsu.sh').with(
        user:    'oracle',
        group:   'oinstall'
      )

      expect(chef_run).to create_file('/opt/oracle/middleware_xxx/utils/bsu/bsu.sh').with(
        owner: 'oracle',
        group: 'oinstall',
        mode:  '0755'
      )

      expect(chef_run).to install_fmw_bsu_bsu('YUIS').with(
        patch_id:            'YUIS',
        middleware_home_dir: '/opt/oracle/middleware_xxx',
        os_user:             'oracle'
      )
    end

  end


end
