#
# Cookbook Name:: fmw_inst
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_inst::webcenter' do

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
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '10.3.6'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['webcenter_source_file']   = '/software/ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip'
        node.set['fmw_inst']['webcenter_source_2_file'] = '/software/ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end


  context 'With all attributes, Typical, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '10.3.6'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['webcenter_source_file']   = '/software/ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip'
        node.set['fmw_inst']['webcenter_source_2_file'] = '/software/ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip'
        node.set['fmw_inst']['install_type'] = 'Typical'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end

  context 'With all attributes, 10.3.6, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_inst']['webcenter_source_file']   = '/software/ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip'
        node.set['fmw_inst']['webcenter_source_2_file'] = '/software/ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end


  context 'With unknown install_type, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '10.3.6'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['webcenter_source_file']   = '/software/ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip'
        node.set['fmw_inst']['webcenter_source_2_file'] = '/software/ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip'
        node.set['fmw_inst']['install_type'] = 'xxx'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end

  context 'With all attributes 10.3.6, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6', log_level: :debug, step_into: ['fmw_inst_fmw_extract','fmw_inst_fmw_install_linux']) do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_inst']['webcenter_source_file']   = '/software/ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip'
        node.set['fmw_inst']['webcenter_source_2_file'] = '/software/ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('webcenter').with(
        source_file:   '/software/ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip',
        source_2_file: '/software/ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip',
        os_user:       'oracle',
        os_group:      'oinstall',
        tmp_dir:       '/tmp'
      )
      expect(chef_run).to install_fmw_inst_fmw_install('webcenter').with(
        oracle_home_dir: '/opt/oracle/middleware_xxx/Oracle_WC1',
        java_home_dir:   '/usr/java/jdk1.7.0_75',
        orainst_dir:     '/etc',
        os_user:         'oracle',
        os_group:        'oinstall',
        tmp_dir:         '/tmp',
        version:         '10.3.6',
        rsp_file:        '/tmp/wc_fmw_11g.rsp',
        installer_file:  '/tmp/webcenter/Disk1/runInstaller'
      )


      expect(chef_run).to create_template('/tmp/wc_fmw_11g.rsp').with(
        source: 'fmw_11g.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
        	          :oracle_home => "/opt/oracle/middleware_xxx/Oracle_WC1",
        	          :install_type => "",
                    :option_array=>["APPSERVER_TYPE=WLS", "APPSERVER_LOCATION=/opt/oracle/middleware_xxx"]}
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract webcenter file 1').with(
        command: 'unzip -o /software/ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip -d /tmp/webcenter',
        cwd: '/tmp',
        user: 'oracle',
        group: 'oinstall'
      )
      expect(chef_run).to run_execute('extract webcenter file 2').with(
        command: 'unzip -o /software/ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip -d /tmp/webcenter',
        cwd: '/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install webcenter').with(
        command: '/tmp/webcenter/Disk1/runInstaller -silent -response /tmp/wc_fmw_11g.rsp -waitforcompletion -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs -jreLoc /usr/java/jdk1.7.0_75 -Djava.io.tmpdir=/tmp',
        cwd: '/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      chef_run # This should not raise an error
    end

  end

  context 'With all attributes 10.3.6, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'windows', version: '2012R2', step_into: ['fmw_inst_fmw_extract_windows','fmw_inst_fmw_install_windows']) do |node|
        node.set['fmw']['java_home_dir']                = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = 'c:\\oracle\\middleware_xxx'
        node.set['fmw_jdk']['source_file']              = 'c:\\software\\jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file']              = 'c:\\software\\wls1036_generic.jar'
        node.set['fmw_inst']['webcenter_source_file']   = 'c:\\software\\ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip'
        node.set['fmw_inst']['webcenter_source_2_file'] = 'c:\\software\\ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('webcenter').with(
        source_file:   'c:\\software\\ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip',
        source_2_file: 'c:\\software\\ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip',
        tmp_dir:       'C:/temp'
      )
      expect(chef_run).to install_fmw_inst_fmw_install('webcenter').with(
        oracle_home_dir: 'c:\\oracle\\middleware_xxx/Oracle_WC1',
        java_home_dir:   'c:\\java\\jdk1.7.0_75',
        tmp_dir:         'C:/temp',
        version:         '10.3.6',
        rsp_file:        'C:/temp/wc_fmw_11g.rsp',
        installer_file:  'C:/temp/webcenter/Disk1/setup.exe'
      )

      expect(chef_run).to create_template('C:/temp/wc_fmw_11g.rsp').with(
        source: 'fmw_11g.rsp',
        variables: {:middleware_home_dir => "c:\\oracle\\middleware_xxx",
                    :oracle_home => "c:\\oracle\\middleware_xxx/Oracle_WC1",
                    :install_type => "",
                    :option_array => ["APPSERVER_TYPE=WLS", "APPSERVER_LOCATION=c:\\oracle\\middleware_xxx"]}
      )

      expect(chef_run).to run_execute('extract webcenter file 1').with(
        command: 'c:\\oracle\\middleware_xxx\\wlserver_10.3\\server\\adr\\unzip.exe -o c:\\software\\ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip -d C:/temp/webcenter',
        cwd: 'C:/temp'
      )

      expect(chef_run).to run_execute('extract webcenter file 2').with(
        command: 'c:\\oracle\\middleware_xxx\\wlserver_10.3\\server\\adr\\unzip.exe -o c:\\software\\ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip -d C:/temp/webcenter',
        cwd: 'C:/temp'
      )

      expect(chef_run).to run_execute('Install webcenter').with(
        command: 'C:/temp/webcenter/Disk1/setup.exe -silent -response C:/temp/wc_fmw_11g.rsp -waitforcompletion -jreLoc c:\\java\\jdk1.7.0_75 -ignoreSysPrereqs -Djava.io.tmpdir=C:/temp',
        cwd: 'C:/temp'
      )

      chef_run # This should not raise an error
    end

  end

  context 'With all attributes 11.1.1, on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'solaris2', version: '5.11', step_into: ['fmw_inst_fmw_extract','fmw_inst_fmw_install_solaris']) do |node|
        node.set['fmw']['java_home_dir']                = '/usr/jdk/instances/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-solaris-i586.tar.gz'
        node.set['fmw_jdk']['source_x64_file']          = '/software/jdk-7u75-solaris-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_inst']['webcenter_source_file']   = '/software/ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip'
        node.set['fmw_inst']['webcenter_source_2_file'] = '/software/ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('webcenter').with(
        source_file:   '/software/ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip',
        source_2_file: '/software/ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip',
        os_user:       'oracle',
        os_group:      'oinstall',
        tmp_dir:       '/var/tmp'
      )
      expect(chef_run).to install_fmw_inst_fmw_install('webcenter').with(
        oracle_home_dir: '/opt/oracle/middleware_xxx/Oracle_WC1',
        java_home_dir:   '/usr/jdk/instances/jdk1.7.0_75',
        orainst_dir:     '/var/opt/oracle',
        os_user:         'oracle',
        os_group:        'oinstall',
        tmp_dir:         '/var/tmp',
        version:         '10.3.6',
        rsp_file:        '/var/tmp/wc_fmw_11g.rsp',
        installer_file:  '/var/tmp/webcenter/Disk1/runInstaller'
      )

      expect(chef_run).to create_template('/var/tmp/wc_fmw_11g.rsp').with(
        source: 'fmw_11g.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
                  :oracle_home => "/opt/oracle/middleware_xxx/Oracle_WC1",
                  :install_type => "",
                  :option_array=>["APPSERVER_TYPE=WLS", "APPSERVER_LOCATION=/opt/oracle/middleware_xxx"]}
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract webcenter file 1').with(
        command: 'unzip -o /software/ofm_wc_generic_11.1.1.9.0_disk1_1of2.zip -d /var/tmp/webcenter',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )
      expect(chef_run).to run_execute('extract webcenter file 2').with(
        command: 'unzip -o /software/ofm_wc_generic_11.1.1.9.0_disk1_2of2.zip -d /var/tmp/webcenter',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install webcenter').with(
        command: '/var/tmp/webcenter/Disk1/runInstaller -silent -response /var/tmp/wc_fmw_11g.rsp -waitforcompletion -invPtrLoc /var/opt/oracle/oraInst.loc -ignoreSysPrereqs -jreLoc /usr/jdk/instances/jdk1.7.0_75 -Djava.io.tmpdir=/var/tmp',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      chef_run # This should not raise an error
    end

  end


end
