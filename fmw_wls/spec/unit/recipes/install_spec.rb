#
# Cookbook Name:: fmw_wls
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_wls::install' do

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /Not supported Operation System, please use it on windows, linux or solaris host/)
    end

  end

  context 'When all attributes are default, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      # expect(chef_run).to include_recipe('fmw_jdk::install')
      expect {chef_run}.to raise_error(RuntimeError, /fmw_jdk attributes cannot be empty/)
    end

  end

  context 'With only jdk attributes and wls java_home_dir, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_40'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-linux-x64.rpm'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(Chef::Exceptions::ValidationFailed, /Required argument source_file is missing!/)
    end

  end

  context 'With attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6', step_into: ['fmw_wls_wls_linux']) do |node|
        node.set['fmw']['java_home_dir']   = '/usr/java/jdk1.8.0_40'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-linux-x64.rpm'
        node.set['fmw_wls']['source_file'] = '/software/wls_generic.jar'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_jdk::install')
      expect(chef_run).to install_fmw_wls_wls('/opt/oracle/middleware').with(
        java_home_dir:       '/usr/java/jdk1.8.0_40',
        source_file:         '/software/wls_generic.jar',
        version:             '12.1.3',
        install_type:        'wls',
        middleware_home_dir: '/opt/oracle/middleware',
        ora_inventory_dir:   '/home/oracle/oraInventory',
        orainst_dir:         '/etc',
        os_user:             'oracle',
        os_group:            'oinstall',
        tmp_dir:             '/tmp'
      )
      expect(chef_run).to create_template('/etc/oraInst.loc').with(
        mode:   0755
      )
      expect(chef_run).to create_directory('/home/oracle/oraInventory').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_directory('/opt/oracle').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_directory('/opt/oracle/middleware').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_template('/tmp/wls_12c.rsp').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0755
      )
      expect(chef_run).to run_execute('Install WLS').with(
        command: '/usr/java/jdk1.8.0_40/bin/java  -Xmx1024m -Djava.io.tmpdir=/tmp -jar /software/wls_generic.jar -silent -responseFile /tmp/wls_12c.rsp -invPtrLoc /etc/oraInst.loc'
      )
    end

  end

  context 'With WebLogic 10.3.6 attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6', step_into: ['fmw_wls_wls_linux']) do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.7.0_75'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-7u75-linux-x64.rpm'
        node.set['fmw_wls']['source_file'] = '/software/wls_generic.jar'
        node.set['fmw']['version'] = '10.3.6'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_jdk::install')
      expect(chef_run).to install_fmw_wls_wls('/opt/oracle/middleware').with(
        java_home_dir:       '/usr/java/jdk1.7.0_75',
        source_file:         '/software/wls_generic.jar',
        version:             '10.3.6',
        install_type:        'wls',
        middleware_home_dir: '/opt/oracle/middleware',
        ora_inventory_dir:   '/home/oracle/oraInventory',
        orainst_dir:         '/etc',
        os_user:             'oracle',
        os_group:            'oinstall',
        tmp_dir:             '/tmp'
      )
      expect(chef_run).to create_template('/etc/oraInst.loc').with(
        mode:   0755
      )
      expect(chef_run).to create_directory('/home/oracle/oraInventory').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_directory('/opt/oracle').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_directory('/opt/oracle/middleware').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_template('/tmp/wls_11g.rsp').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0755
      )
      expect(chef_run).to run_execute('Install WLS').with(
        command: '/usr/java/jdk1.7.0_75/bin/java  -Xmx1024m -Djava.io.tmpdir=/tmp -Duser.country=US -Duser.language=en -jar /software/wls_generic.jar -mode=silent -silent_xml=/tmp/wls_11g.rsp -log=/tmp/wls.log -log_priority=info'
      )
    end

  end

  context 'With custom attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6', step_into: ['fmw_wls_wls_linux']) do |node|
        node.set['fmw']['java_home_dir']         = '/usr/java/jdk1.8.0_40'
        node.set['fmw']['middleware_home_dir']   = '/opt/oracle/middleware_XXXX'
        node.set['fmw']['os_user']               = 'wls'
        node.set['fmw']['os_group']              = 'dba'
        node.set['fmw']['tmp_dir']               = '/var/tmp'
        node.set['fmw']['ora_inventory_dir']     = '/home/wls/oraInventory'
        node.set['fmw_jdk']['source_file']       = '/software/jdk-8u40-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']       = '/software/wls_generic.jar'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_jdk::install')
      expect(chef_run).to install_fmw_wls_wls('/opt/oracle/middleware_XXXX').with(
        java_home_dir:       '/usr/java/jdk1.8.0_40',
        source_file:         '/software/wls_generic.jar',
        version:             '12.1.3',
        install_type:        'wls',
        middleware_home_dir: '/opt/oracle/middleware_XXXX',
        ora_inventory_dir:   '/home/wls/oraInventory',
        orainst_dir:         '/etc',
        os_user:             'wls',
        os_group:            'dba',
        tmp_dir:             '/var/tmp'
      )
      expect(chef_run).to create_template('/etc/oraInst.loc').with(
        mode:   0755
      )
      expect(chef_run).to create_directory('/home/wls/oraInventory').with(
        owner:  'wls',
        group:  'dba',
        mode:   0775
      )
      expect(chef_run).to create_directory('/opt/oracle').with(
        owner:  'wls',
        group:  'dba',
        mode:   0775
      )
      expect(chef_run).to create_directory('/opt/oracle/middleware_XXXX').with(
        owner:  'wls',
        group:  'dba',
        mode:   0775
      )
      expect(chef_run).to create_template('/var/tmp/wls_12c.rsp').with(
        owner:  'wls',
        group:  'dba',
        mode:   0755
      )
      expect(chef_run).to run_execute('Install WLS').with(
        command: '/usr/java/jdk1.8.0_40/bin/java  -Xmx1024m -Djava.io.tmpdir=/var/tmp -jar /software/wls_generic.jar -silent -responseFile /var/tmp/wls_12c.rsp -invPtrLoc /etc/oraInst.loc'
      )
    end

  end

  context 'With attributes, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2', step_into: ['fmw_wls_wls_windows']) do |node|
        node.set['fmw']['java_home_dir'] = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file'] = '/software/wls_generic.jar'
        node.set['fmw']['version'] = '12.2.1'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_jdk::install')
      expect(chef_run).to create_registry_key_if_missing('HKEY_LOCAL_MACHINE\SOFTWARE\Oracle')
      expect(chef_run).to install_fmw_wls_wls('C:/oracle/middleware').with(
        java_home_dir:       'c:\\java\\jdk1.7.0_75',
        source_file:         '/software/wls_generic.jar',
        version:             '12.2.1',
        install_type:        'wls',
        middleware_home_dir: 'C:/oracle/middleware',
        ora_inventory_dir:   'C:\\Program Files\\Oracle\\Inventory',
        tmp_dir:             'C:/temp'
      )
      expect(chef_run).to create_template('C:/temp/wls_12c.rsp')
      expect(chef_run).to run_execute('Install WLS').with(
        command: 'c:\\java\\jdk1.7.0_75\\bin\\java.exe -Xmx1024m -Djava.io.tmpdir=C:/temp -jar /software/wls_generic.jar -silent -responseFile C:/temp/wls_12c.rsp -logLevel fine'
      )
    end

  end

  context 'With WebLogic 10.3.6 attributes, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2', step_into: ['fmw_wls_wls_windows']) do |node|
        node.set['fmw']['java_home_dir'] = 'c:\\java\\jdk1.7.0_75'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-7u75-windows-x64.exe'
        node.set['fmw_wls']['source_file'] = '/software/wls1036_generic.jar'
        node.set['fmw']['version'] = '10.3.6'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_jdk::install')
      expect(chef_run).to create_registry_key_if_missing('HKEY_LOCAL_MACHINE\SOFTWARE\Oracle')
      expect(chef_run).to install_fmw_wls_wls('C:/oracle/middleware').with(
        java_home_dir:       'c:\\java\\jdk1.7.0_75',
        source_file:         '/software/wls1036_generic.jar',
        version:             '10.3.6',
        install_type:        'wls',
        middleware_home_dir: 'C:/oracle/middleware',
        ora_inventory_dir:   'C:\\Program Files\\Oracle\\Inventory',
        tmp_dir:             'C:/temp'
      )
      expect(chef_run).to create_template('C:/temp/wls_11g.rsp')
      expect(chef_run).to run_execute('Install WLS').with(
        command: 'c:\\java\\jdk1.7.0_75\\bin\\java.exe -Xmx1024m -Djava.io.tmpdir=C:/temp -Duser.country=US -Duser.language=en -jar /software/wls1036_generic.jar -mode=silent -silent_xml=C:/temp/wls_11g.rsp -log=C:/temp/wls.log -log_priority=info'
      )
    end

  end

  context 'With attributes, on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11', step_into: ['fmw_wls_wls_solaris'])do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_40'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-solaris-x64.tar.gz'
        node.set['fmw_wls']['source_file'] = '/software/wls_generic.jar'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_jdk::install')
      expect(chef_run).to install_fmw_wls_wls('/opt/oracle/middleware')
      expect(chef_run).to create_directory('/var/opt/oracle').with(
        mode:   0755
      )
      expect(chef_run).to create_template('/var/opt/oracle/oraInst.loc').with(
        mode:   0755
      )
      expect(chef_run).to create_directory('/export/home/oracle/oraInventory').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_directory('/opt/oracle').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_directory('/opt/oracle/middleware').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_template('/var/tmp/wls_12c.rsp').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0755
      )
      expect(chef_run).to run_execute('Install WLS').with(
        command: '/usr/java/jdk1.8.0_40/bin/java -d64 -Xmx1024m -Djava.io.tmpdir=/var/tmp -jar /software/wls_generic.jar -silent -responseFile /var/tmp/wls_12c.rsp -invPtrLoc /var/opt/oracle/oraInst.loc'
      )
    end

  end

  context 'With WebLogic 10.3.6 attributes, on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11', step_into: ['fmw_wls_wls_solaris'])do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_40'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-solaris-x64.tar.gz'
        node.set['fmw_wls']['source_file'] = '/software/wls_generic.jar'
        node.set['fmw']['version'] = '10.3.6'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_jdk::install')
      expect(chef_run).to install_fmw_wls_wls('/opt/oracle/middleware')
      expect(chef_run).to create_directory('/var/opt/oracle').with(
        mode:   0755
      )
      expect(chef_run).to create_template('/var/opt/oracle/oraInst.loc').with(
        mode:   0755
      )
      expect(chef_run).to create_directory('/export/home/oracle/oraInventory').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_directory('/opt/oracle').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_directory('/opt/oracle/middleware').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0775
      )
      expect(chef_run).to create_template('/var/tmp/wls_11g.rsp').with(
        owner:  'oracle',
        group:  'oinstall',
        mode:   0755
      )
      expect(chef_run).to run_execute('Install WLS').with(
        command: '/usr/java/jdk1.8.0_40/bin/java -d64 -Xmx1024m -Djava.io.tmpdir=/var/tmp -Duser.country=US -Duser.language=en -jar /software/wls_generic.jar -mode=silent -silent_xml=/var/tmp/wls_11g.rsp -log=/var/tmp/wls.log -log_priority=info'
      )
    end

  end

  context 'With custom attributes, on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11', step_into: ['fmw_wls_wls_solaris'])do |node|
        node.set['fmw']['java_home_dir']         = '/usr/java/jdk1.8.0_40'
        node.set['fmw_jdk']['source_file']       = '/software/jdk-8u40-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']       = '/software/wls_generic.jar'
        node.set['fmw']['middleware_home_dir']   = '/opt/oracle/middleware_XXXX'
        node.set['fmw']['os_user']               = 'wls'
        node.set['fmw']['os_group']              = 'dba'
        node.set['fmw']['tmp_dir']               = '/var/tmp'
        node.set['fmw']['ora_inventory_dir']     = '/export/home/wls/oraInventory'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to include_recipe('fmw_jdk::install')
      expect(chef_run).to install_fmw_wls_wls('/opt/oracle/middleware_XXXX')
      expect(chef_run).to create_directory('/var/opt/oracle').with(
        mode:   0755
      )
      expect(chef_run).to create_template('/var/opt/oracle/oraInst.loc').with(
        mode:   0755
      )
      expect(chef_run).to create_directory('/export/home/wls/oraInventory').with(
        owner:  'wls',
        group:  'dba',
        mode:   0775
      )
      expect(chef_run).to create_directory('/opt/oracle').with(
        mode:   0775,
        owner:  'wls',
        group:  'dba'
      )
      expect(chef_run).to create_directory('/opt/oracle/middleware_XXXX').with(
        owner:  'wls',
        group:  'dba',
        mode:   0775
      )
      expect(chef_run).to create_template('/var/tmp/wls_12c.rsp').with(
        owner:  'wls',
        group:  'dba',
        mode:   0755
      )
      expect(chef_run).to run_execute('Install WLS').with(
        command: '/usr/java/jdk1.8.0_40/bin/java -d64 -Xmx1024m -Djava.io.tmpdir=/var/tmp -jar /software/wls_generic.jar -silent -responseFile /var/tmp/wls_12c.rsp -invPtrLoc /var/opt/oracle/oraInst.loc'
      )
    end

  end

end
