#
# Cookbook Name:: fmw_inst
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_inst::mft' do

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /Not supported Operation System, please use it on windows, linux or solaris host/)
    end

  end

  context 'With only jdk attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.7.0_75'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-7u75-linux-x64.tar.gz'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(Chef::Exceptions::ValidationFailed, /Required argument source_file is missing!/)
    end

  end

  context 'With jdk and wls attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']     = '/usr/java/jdk1.7.0_75'
        node.set['fmw_jdk']['source_file']   = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']   = '/software/fmw_12.1.3.0.0_infrastructure.jar'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /fmw_inst attributes cannot be empty/)
    end

  end

  context 'With all attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '12.1.3'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['mft_source_file'] = '/software/fmw_12.1.3.0.0_mft_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end


  context 'With all attributes, SOA Suite, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '12.1.3'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['mft_source_file'] = '/software/fmw_12.1.3.0.0_mft_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end

  context 'With all attributes 12.1.3, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6', step_into: ['fmw_inst_fmw_extract','fmw_inst_fmw_install_linux']) do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '12.1.3'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['mft_source_file']         = '/software/fmw_12.1.3.0.0_mft_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('mft')
      expect(chef_run).to install_fmw_inst_fmw_install('mft')

      expect(chef_run).to create_template('/tmp/mft_fmw_12c.rsp').with(
        source: 'fmw_12c.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
        	          :oracle_home => "/opt/oracle/middleware_xxx/mft/bin",
        	          :install_type => "Typical",
                    :option_array =>[] }
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract mft file 1').with(
        command: 'unzip -o /software/fmw_12.1.3.0.0_mft_Disk1_1of1.zip -d /tmp/mft',
        cwd: '/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install mft').with(
        command: '/usr/java/jdk1.7.0_75/bin/java  -Xmx1024m -Djava.io.tmpdir=/tmp -jar /tmp/mft/fmw_12.1.3.0.0_mft.jar -waitforcompletion -silent -responseFile /tmp/mft_fmw_12c.rsp -invPtrLoc /etc/oraInst.loc -jreLoc /usr/java/jdk1.7.0_75',
        cwd: '/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      chef_run # This should not raise an error
    end

  end

  context 'With all attributes 12.1.3, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2', step_into: ['fmw_inst_fmw_extract_windows','fmw_inst_fmw_install_windows']) do |node|
        node.set['fmw']['java_home_dir']                = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw']['version']                      = '12.1.3'
        node.set['fmw']['middleware_home_dir']          = 'c:\\oracle\\middleware_xxx'
        node.set['fmw_jdk']['source_file']              = 'c:\\software\\jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file']              = 'c:\\software\\fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['mft_source_file'] = 'c:\\software\\fmw_12.1.3.0.0_mft_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('mft')
      expect(chef_run).to install_fmw_inst_fmw_install('mft')

      expect(chef_run).to create_template('C:/temp/mft_fmw_12c.rsp').with(
        source: 'fmw_12c.rsp',
        variables: {:middleware_home_dir => "c:\\oracle\\middleware_xxx",
                    :oracle_home => "c:\\oracle\\middleware_xxx/mft/bin",
                    :install_type => "Typical",
                    :option_array => [] }
      )

      expect(chef_run).to run_execute('extract mft file 1').with(
        command: 'c:\\oracle\\middleware_xxx\\oracle_common\\adr\\unzip.exe -o c:\\software\\fmw_12.1.3.0.0_mft_Disk1_1of1.zip -d C:/temp/mft',
        cwd: 'C:/temp'
      )

      expect(chef_run).to run_execute('Install mft').with(
        command: 'c:\\java\\jdk1.7.0_75\\bin\\java.exe -Xmx1024m -Djava.io.tmpdir=C:/temp -jar C:/temp/mft/fmw_12.1.3.0.0_mft.jar -waitforcompletion -silent -responseFile C:/temp/mft_fmw_12c.rsp -jreLoc c:\\java\\jdk1.7.0_75',
        cwd: 'C:/temp'
      )

      chef_run # This should not raise an error
    end

  end

  context 'With all attributes 12.1.3, on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'solaris2', version: '5.11', step_into: ['fmw_inst_fmw_extract','fmw_inst_fmw_install_solaris']) do |node|
        node.set['fmw']['java_home_dir']                = '/usr/jdk/instances/jdk1.7.0_75'
        node.set['fmw']['version']                      = '12.1.3'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-solaris-i586.tar.gz'
        node.set['fmw_jdk']['source_x64_file']          = '/software/jdk-7u75-solaris-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['mft_source_file'] = '/software/fmw_12.1.3.0.0_mft_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('mft')
      expect(chef_run).to install_fmw_inst_fmw_install('mft')

      expect(chef_run).to create_template('/var/tmp/mft_fmw_12c.rsp').with(
        source: 'fmw_12c.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
                    :oracle_home => "/opt/oracle/middleware_xxx/mft/bin",
                    :install_type => "Typical",
                    :option_array => []}
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract mft file 1').with(
        command: 'unzip -o /software/fmw_12.1.3.0.0_mft_Disk1_1of1.zip -d /var/tmp/mft',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install mft').with(
        command: '/usr/jdk/instances/jdk1.7.0_75/bin/java -d64 -Xmx1024m -Djava.io.tmpdir=/var/tmp -jar /var/tmp/mft/fmw_12.1.3.0.0_mft.jar -waitforcompletion -silent -responseFile /var/tmp/mft_fmw_12c.rsp -invPtrLoc /var/opt/oracle/oraInst.loc -jreLoc /usr/jdk/instances/jdk1.7.0_75',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      chef_run # This should not raise an error
    end

  end

end
