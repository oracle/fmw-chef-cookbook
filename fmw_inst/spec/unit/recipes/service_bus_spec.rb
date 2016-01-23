#
# Cookbook Name:: fmw_inst
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_inst::service_bus' do

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
        node.set['fmw_inst']['service_bus_source_file'] = '/software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
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
        node.set['fmw_inst']['service_bus_source_file'] = '/software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
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
        node.set['fmw_inst']['java_home_dir']           = '/usr/java/jdk1.7.0_75'
        node.set['fmw_inst']['service_bus_source_file'] = '/software/ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip'
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
        node.set['fmw_inst']['service_bus_source_file'] = '/software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('service_bus')
      expect(chef_run).to install_fmw_inst_fmw_install('service_bus')

      expect(chef_run).to create_template('/tmp/sb_fmw_12c.rsp').with(
        source: 'fmw_12c.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
        	          :oracle_home => "/opt/oracle/middleware_xxx/osb/bin",
        	          :install_type => "Service Bus",
                    :option_array =>[] }
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract service_bus file 1').with(
        command: 'unzip -o /software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip -d /tmp/service_bus',
        cwd: '/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install service_bus').with(
        command: '/usr/java/jdk1.7.0_75/bin/java  -Xmx1024m -Djava.io.tmpdir=/tmp -jar /tmp/service_bus/fmw_12.1.3.0.0_osb.jar -waitforcompletion -silent -responseFile /tmp/sb_fmw_12c.rsp -invPtrLoc /etc/oraInst.loc -jreLoc /usr/java/jdk1.7.0_75',
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
        node.set['fmw_inst']['service_bus_source_file'] = '/software/ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('service_bus')
      expect(chef_run).to install_fmw_inst_fmw_install('service_bus')

      expect(chef_run).to create_template('/tmp/sb_fmw_11g.rsp').with(
        source: 'fmw_11g.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
        	          :oracle_home => "/opt/oracle/middleware_xxx/Oracle_OSB1",
        	          :install_type => "",
                    :option_array => ["TYPICAL TYPE=false", "CUSTOM TYPE=true", "Oracle Service Bus Examples=false", "Oracle Service Bus IDE=false", "WL_HOME=/opt/oracle/middleware_xxx/wlserver_10.3"]}
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract service_bus file 1').with(
        command: 'unzip -o /software/ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip -d /tmp/service_bus',
        cwd: '/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install service_bus').with(
        command: '/tmp/service_bus/Disk1/runInstaller -silent -response /tmp/sb_fmw_11g.rsp -waitforcompletion -invPtrLoc /etc/oraInst.loc -ignoreSysPrereqs -jreLoc /usr/java/jdk1.7.0_75 -Djava.io.tmpdir=/tmp',
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
        node.set['fmw_inst']['service_bus_source_file'] = 'c:\\software\\fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('service_bus')
      expect(chef_run).to install_fmw_inst_fmw_install('service_bus')

      expect(chef_run).to create_template('C:/temp/sb_fmw_12c.rsp').with(
        source: 'fmw_12c.rsp',
        variables: {:middleware_home_dir => "c:\\oracle\\middleware_xxx",
                    :oracle_home => "c:\\oracle\\middleware_xxx/osb/bin",
                    :install_type => "Service Bus",
                    :option_array => [] }
      )

      expect(chef_run).to run_execute('extract service_bus file 1').with(
        command: 'c:\\oracle\\middleware_xxx\\oracle_common\\adr\\unzip.exe -o c:\\software\\fmw_12.1.3.0.0_osb_Disk1_1of1.zip -d C:/temp/service_bus',
        cwd: 'C:/temp'
      )

      expect(chef_run).to run_execute('Install service_bus').with(
        command: 'c:\\java\\jdk1.7.0_75\\bin\\java.exe -Xmx1024m -Djava.io.tmpdir=C:/temp -jar C:/temp/service_bus/fmw_12.1.3.0.0_osb.jar -waitforcompletion -silent -responseFile C:/temp/sb_fmw_12c.rsp -jreLoc c:\\java\\jdk1.7.0_75',
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
        node.set['fmw_inst']['service_bus_source_file'] = 'c:\\software\\ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('service_bus')
      expect(chef_run).to install_fmw_inst_fmw_install('service_bus')

      expect(chef_run).to create_template('C:/temp/sb_fmw_11g.rsp').with(
        source: 'fmw_11g.rsp',
        variables: {:middleware_home_dir => "c:\\oracle\\middleware_xxx",
                    :oracle_home => "c:\\oracle\\middleware_xxx/Oracle_OSB1",
                    :install_type => "",
                    :option_array=>["TYPICAL TYPE=false", "CUSTOM TYPE=true", "Oracle Service Bus Examples=false", "Oracle Service Bus IDE=false", "WL_HOME=c:\\oracle\\middleware_xxx/wlserver_10.3"]}
      )

      expect(chef_run).to run_execute('extract service_bus file 1').with(
        command: 'c:\\oracle\\middleware_xxx\\wlserver_10.3\\server\\adr\\unzip.exe -o c:\\software\\ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip -d C:/temp/service_bus',
        cwd: 'C:/temp'
      )

      expect(chef_run).to run_execute('Install service_bus').with(
        command: 'C:/temp/service_bus/Disk1/setup.exe -silent -response C:/temp/sb_fmw_11g.rsp -waitforcompletion -jreLoc c:\\java\\jdk1.7.0_75 -ignoreSysPrereqs -Djava.io.tmpdir=C:/temp',
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
        node.set['fmw_inst']['service_bus_source_file'] = '/software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('service_bus')
      expect(chef_run).to install_fmw_inst_fmw_install('service_bus')

      expect(chef_run).to create_template('/var/tmp/sb_fmw_12c.rsp').with(
        source: 'fmw_12c.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
                    :oracle_home => "/opt/oracle/middleware_xxx/osb/bin",
                    :install_type => "Service Bus",
                    :option_array => []}
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract service_bus file 1').with(
        command: 'unzip -o /software/fmw_12.1.3.0.0_osb_Disk1_1of1.zip -d /var/tmp/service_bus',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install service_bus').with(
        command: '/usr/jdk/instances/jdk1.7.0_75/bin/java -d64 -Xmx1024m -Djava.io.tmpdir=/var/tmp -jar /var/tmp/service_bus/fmw_12.1.3.0.0_osb.jar -waitforcompletion -silent -responseFile /var/tmp/sb_fmw_12c.rsp -invPtrLoc /var/opt/oracle/oraInst.loc -jreLoc /usr/jdk/instances/jdk1.7.0_75',
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
        node.set['fmw_inst']['service_bus_source_file'] = '/software/ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_wls::install')
      expect(chef_run).to extract_fmw_inst_fmw_extract('service_bus')
      expect(chef_run).to install_fmw_inst_fmw_install('service_bus')

      expect(chef_run).to create_template('/var/tmp/sb_fmw_11g.rsp').with(
        source: 'fmw_11g.rsp',
        mode:   0755,
        owner: 'oracle',
        group: 'oinstall',
        variables: {:middleware_home_dir => "/opt/oracle/middleware_xxx",
                    :oracle_home => "/opt/oracle/middleware_xxx/Oracle_OSB1",
                    :install_type => "",
                    :option_array => ["TYPICAL TYPE=false", "CUSTOM TYPE=true", "Oracle Service Bus Examples=false", "Oracle Service Bus IDE=false", "WL_HOME=/opt/oracle/middleware_xxx/wlserver_10.3"]}
      )

      # expect(chef_run).to install_package('unzip')
      expect(chef_run).to run_execute('extract service_bus file 1').with(
        command: 'unzip -o /software/ofm_osb_generic_11.1.1.7.0_disk1_1of1.zip -d /var/tmp/service_bus',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      expect(chef_run).to run_execute('Install service_bus').with(
        command: '/var/tmp/service_bus/Disk1/runInstaller -silent -response /var/tmp/sb_fmw_11g.rsp -waitforcompletion -invPtrLoc /var/opt/oracle/oraInst.loc -ignoreSysPrereqs -jreLoc /usr/jdk/instances/jdk1.7.0_75 -Djava.io.tmpdir=/var/tmp',
        cwd: '/var/tmp',
        user: 'oracle',
        group: 'oinstall'
      )

      chef_run # This should not raise an error
    end

  end


end
