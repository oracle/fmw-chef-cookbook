#
# Cookbook Name:: fmw_inst
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_inst::soa_suite' do

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
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = '/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
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
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = '/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
        node.set['fmw_inst']['soa_suite_install_type'] = 'SOA Suite'
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
        node.set['fmw_inst']['soa_suite_source_file']   = '/software/ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip'
        node.set['fmw_inst']['soa_suite_source_2_file'] = '/software/ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end


  context 'With unknown soa_suite_install_type, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = '/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
        node.set['fmw_inst']['soa_suite_install_type'] = 'xxx'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /unknown soa_suite_install_type please use BPM|SOA Suite/)
    end

  end

  context 'With all attributes 12.1.3, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6', step_into: ['fmw_inst_fmw_extract','fmw_inst_fmw_install_linux']) do |node|
        node.set['fmw']['java_home_dir']               = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = '/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('soa_suite').with(
        source_file:   '/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip',
        source_2_file: nil,
        os_user:       'oracle',
        os_group:      'oinstall',
        tmp_dir:       '/tmp'
      )
      expect(chef_run).to install_fmw_inst_fmw_install('soa_suite').with(
        oracle_home_dir: '/opt/oracle/middleware_xxx/soa/bin',
        java_home_dir:   '/usr/java/jdk1.7.0_75',
        orainst_dir:     '/etc',
        os_user:         'oracle',
        os_group:        'oinstall',
        tmp_dir:         '/tmp',
        version:         '12.1.3',
        rsp_file:        '/tmp/soa_fmw_12c.rsp',
        installer_file:  '/tmp/soa_suite/fmw_12.1.3.0.0_soa.jar'
      )

      expect(chef_run).to create_template('/tmp/soa_fmw_12c.rsp').with(
        source: 'fmw_12c.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
        	          :oracle_home => "/opt/oracle/middleware_xxx/soa/bin",
        	          :install_type => "SOA Suite",
                    :option_array=>[]}
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract soa_suite file 1').with(
        command: 'unzip -o /software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip -d /tmp/soa_suite',
        cwd: '/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install soa_suite').with(
        command: '/usr/java/jdk1.7.0_75/bin/java  -Xmx1024m -Djava.io.tmpdir=/tmp -jar /tmp/soa_suite/fmw_12.1.3.0.0_soa.jar -waitforcompletion -silent -responseFile /tmp/soa_fmw_12c.rsp -invPtrLoc /etc/oraInst.loc -jreLoc /usr/java/jdk1.7.0_75',
        cwd: '/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      chef_run # This should not raise an error
    end

  end

  context 'With all attributes 10.3.6, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '6.6', step_into: ['fmw_inst_fmw_extract','fmw_inst_fmw_install_linux']) do |node|
        node.set['fmw']['java_home_dir']                = '/usr/java/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_inst']['soa_suite_source_file']   = '/software/ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip'
        node.set['fmw_inst']['soa_suite_source_2_file'] = '/software/ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('soa_suite').with(
        source_file:   '/software/ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip',
        source_2_file: '/software/ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip',
        os_user:       'oracle',
        os_group:      'oinstall',
        tmp_dir:       '/tmp'
      )
      expect(chef_run).to install_fmw_inst_fmw_install('soa_suite').with(
        oracle_home_dir: '/opt/oracle/middleware_xxx/Oracle_SOA1',
        java_home_dir:   '/usr/java/jdk1.7.0_75',
        orainst_dir:     '/etc',
        os_user:         'oracle',
        os_group:        'oinstall',
        tmp_dir:         '/tmp',
        version:         '10.3.6',
        rsp_file:        '/tmp/soa_fmw_11g.rsp',
        installer_file:  '/tmp/soa_suite/Disk1/runInstaller'
      )


      expect(chef_run).to create_template('/tmp/soa_fmw_11g.rsp').with(
        source: 'fmw_11g.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
        	          :oracle_home => "/opt/oracle/middleware_xxx/Oracle_SOA1",
        	          :install_type => "",
                    :option_array=>["APPSERVER_TYPE=WLS", "APPSERVER_LOCATION=/opt/oracle/middleware_xxx"]}
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract soa_suite file 1').with(
        command: 'unzip -o /software/ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip -d /tmp/soa_suite',
        cwd: '/tmp',
        user: 'oracle',
        group: 'oinstall'
      )
      expect(chef_run).to run_execute('extract soa_suite file 2').with(
        command: 'unzip -o /software/ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip -d /tmp/soa_suite',
        cwd: '/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install soa_suite').with(
        command: '/tmp/soa_suite/Disk1/runInstaller -silent -response /tmp/soa_fmw_11g.rsp -waitforcompletion -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs -jreLoc /usr/java/jdk1.7.0_75 -Djava.io.tmpdir=/tmp',
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
        node.set['fmw']['java_home_dir']               = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = 'c:\\oracle\\middleware_xxx'
        node.set['fmw_jdk']['source_file']             = 'c:\\software\\jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file']             = 'c:\\software\\fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = 'c:\\software\\fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('soa_suite').with(
        source_file:   'c:\\software\\fmw_12.1.3.0.0_soa_Disk1_1of1.zip',
        source_2_file: nil,
        tmp_dir:       'C:/temp'
      )
      expect(chef_run).to install_fmw_inst_fmw_install('soa_suite').with(
        oracle_home_dir: 'c:\\oracle\\middleware_xxx/soa/bin',
        java_home_dir:   'c:\\java\\jdk1.7.0_75',
        tmp_dir:         'C:/temp',
        version:         '12.1.3',
        rsp_file:        'C:/temp/soa_fmw_12c.rsp',
        installer_file:  'C:/temp/soa_suite/fmw_12.1.3.0.0_soa.jar'
      )

      expect(chef_run).to create_template('C:/temp/soa_fmw_12c.rsp').with(
        source: 'fmw_12c.rsp',
        variables: {:middleware_home_dir => "c:\\oracle\\middleware_xxx",
                    :oracle_home => "c:\\oracle\\middleware_xxx/soa/bin",
                    :install_type => "SOA Suite",
                    :option_array => []}
      )

      expect(chef_run).to run_execute('extract soa_suite file 1').with(
        command: 'c:\\oracle\\middleware_xxx\\oracle_common\\adr\\unzip.exe -o c:\\software\\fmw_12.1.3.0.0_soa_Disk1_1of1.zip -d C:/temp/soa_suite',
        cwd: 'C:/temp'
      )

      expect(chef_run).to run_execute('Install soa_suite').with(
        command: 'c:\\java\\jdk1.7.0_75\\bin\\java.exe -Xmx1024m -Djava.io.tmpdir=C:/temp -jar C:/temp/soa_suite/fmw_12.1.3.0.0_soa.jar -waitforcompletion -silent -responseFile C:/temp/soa_fmw_12c.rsp -jreLoc c:\\java\\jdk1.7.0_75',
        cwd: 'C:/temp'
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
        node.set['fmw_inst']['soa_suite_source_file']   = 'c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip'
        node.set['fmw_inst']['soa_suite_source_2_file'] = 'c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('soa_suite').with(
        source_file:   'c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip',
        source_2_file: 'c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip',
        tmp_dir:       'C:/temp'
      )
      expect(chef_run).to install_fmw_inst_fmw_install('soa_suite').with(
        oracle_home_dir: 'c:\\oracle\\middleware_xxx/Oracle_SOA1',
        java_home_dir:   'c:\\java\\jdk1.7.0_75',
        tmp_dir:         'C:/temp',
        version:         '10.3.6',
        rsp_file:        'C:/temp/soa_fmw_11g.rsp',
        installer_file:  'C:/temp/soa_suite/Disk1/setup.exe'
      )

      expect(chef_run).to create_template('C:/temp/soa_fmw_11g.rsp').with(
        source: 'fmw_11g.rsp',
        variables: {:middleware_home_dir => "c:\\oracle\\middleware_xxx",
                    :oracle_home => "c:\\oracle\\middleware_xxx/Oracle_SOA1",
                    :install_type => "",
                    :option_array => ["APPSERVER_TYPE=WLS", "APPSERVER_LOCATION=c:\\oracle\\middleware_xxx"]}
      )

      expect(chef_run).to run_execute('extract soa_suite file 1').with(
        command: 'c:\\oracle\\middleware_xxx\\wlserver_10.3\\server\\adr\\unzip.exe -o c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip -d C:/temp/soa_suite',
        cwd: 'C:/temp'
      )

      expect(chef_run).to run_execute('extract soa_suite file 2').with(
        command: 'c:\\oracle\\middleware_xxx\\wlserver_10.3\\server\\adr\\unzip.exe -o c:\\software\\ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip -d C:/temp/soa_suite',
        cwd: 'C:/temp'
      )

      expect(chef_run).to run_execute('Install soa_suite').with(
        command: 'C:/temp/soa_suite/Disk1/setup.exe -silent -response C:/temp/soa_fmw_11g.rsp -waitforcompletion -jreLoc c:\\java\\jdk1.7.0_75 -ignoreSysPrereqs -Djava.io.tmpdir=C:/temp',
        cwd: 'C:/temp'
      )

      chef_run # This should not raise an error
    end

  end

  context 'With all attributes 12.1.3, on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'solaris2', version: '5.11', step_into: ['fmw_inst_fmw_extract','fmw_inst_fmw_install_solaris']) do |node|
        node.set['fmw']['java_home_dir']               = '/usr/jdk/instances/jdk1.7.0_75'
        node.set['fmw']['version']                     = '12.1.3'
        node.set['fmw']['middleware_home_dir']         = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']             = '/software/jdk-7u75-solaris-i586.tar.gz'
        node.set['fmw_jdk']['source_x64_file']         = '/software/jdk-7u75-solaris-x64.tar.gz'
        node.set['fmw_wls']['source_file']             = '/software/fmw_12.1.3.0.0_infrastructure.jar'
        node.set['fmw_inst']['soa_suite_source_file']  = '/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('soa_suite').with(
        source_file:   '/software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip',
        source_2_file: nil,
        os_user:       'oracle',
        os_group:      'oinstall',
        tmp_dir:       '/var/tmp'
      )
      expect(chef_run).to install_fmw_inst_fmw_install('soa_suite').with(
        oracle_home_dir: '/opt/oracle/middleware_xxx/soa/bin',
        java_home_dir:   '/usr/jdk/instances/jdk1.7.0_75',
        orainst_dir:     '/var/opt/oracle',
        os_user:         'oracle',
        os_group:        'oinstall',
        tmp_dir:         '/var/tmp',
        version:         '12.1.3',
        rsp_file:        '/var/tmp/soa_fmw_12c.rsp',
        installer_file:  '/var/tmp/soa_suite/fmw_12.1.3.0.0_soa.jar'
      )


      expect(chef_run).to create_template('/var/tmp/soa_fmw_12c.rsp').with(
        source: 'fmw_12c.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
                    :oracle_home => "/opt/oracle/middleware_xxx/soa/bin",
                    :install_type => "SOA Suite",
                    :option_array=>[]}
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract soa_suite file 1').with(
        command: 'unzip -o /software/fmw_12.1.3.0.0_soa_Disk1_1of1.zip -d /var/tmp/soa_suite',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install soa_suite').with(
        command: '/usr/jdk/instances/jdk1.7.0_75/bin/java -d64 -Xmx1024m -Djava.io.tmpdir=/var/tmp -jar /var/tmp/soa_suite/fmw_12.1.3.0.0_soa.jar -waitforcompletion -silent -responseFile /var/tmp/soa_fmw_12c.rsp -invPtrLoc /var/opt/oracle/oraInst.loc -jreLoc /usr/jdk/instances/jdk1.7.0_75',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      chef_run # This should not raise an error
    end

  end

  context 'With all attributes 10.3.6, on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'solaris2', version: '5.11', step_into: ['fmw_inst_fmw_extract','fmw_inst_fmw_install_solaris']) do |node|
        node.set['fmw']['java_home_dir']                = '/usr/jdk/instances/jdk1.7.0_75'
        node.set['fmw']['version']                      = '10.3.6'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-solaris-i586.tar.gz'
        node.set['fmw_jdk']['source_x64_file']          = '/software/jdk-7u75-solaris-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_inst']['soa_suite_source_file']   = '/software/ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip'
        node.set['fmw_inst']['soa_suite_source_2_file'] = '/software/ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('soa_suite').with(
        source_file:   '/software/ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip',
        source_2_file: '/software/ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip',
        os_user:       'oracle',
        os_group:      'oinstall',
        tmp_dir:       '/var/tmp'
      )
      expect(chef_run).to install_fmw_inst_fmw_install('soa_suite').with(
        oracle_home_dir: '/opt/oracle/middleware_xxx/Oracle_SOA1',
        java_home_dir:   '/usr/jdk/instances/jdk1.7.0_75',
        orainst_dir:     '/var/opt/oracle',
        os_user:         'oracle',
        os_group:        'oinstall',
        tmp_dir:         '/var/tmp',
        version:         '10.3.6',
        rsp_file:        '/var/tmp/soa_fmw_11g.rsp',
        installer_file:  '/var/tmp/soa_suite/Disk1/runInstaller'
      )


      expect(chef_run).to create_template('/var/tmp/soa_fmw_11g.rsp').with(
        source: 'fmw_11g.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
                  :oracle_home => "/opt/oracle/middleware_xxx/Oracle_SOA1",
                  :install_type => "",
                  :option_array=>["APPSERVER_TYPE=WLS", "APPSERVER_LOCATION=/opt/oracle/middleware_xxx"]}
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract soa_suite file 1').with(
        command: 'unzip -o /software/ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip -d /var/tmp/soa_suite',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )
      expect(chef_run).to run_execute('extract soa_suite file 2').with(
        command: 'unzip -o /software/ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip -d /var/tmp/soa_suite',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install soa_suite').with(
        command: '/var/tmp/soa_suite/Disk1/runInstaller -silent -response /var/tmp/soa_fmw_11g.rsp -waitforcompletion -invPtrLoc /var/opt/oracle/oraInst.loc -ignoreSysPrereqs -jreLoc /usr/jdk/instances/jdk1.7.0_75 -Djava.io.tmpdir=/var/tmp',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      chef_run # This should not raise an error
    end

  end


end
