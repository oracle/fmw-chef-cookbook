#
# Cookbook Name:: fmw_jdk
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_jdk::install' do

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /Not supported Operation System, please use it on windows, linux or solaris host/)
    end

  end

  context 'With attributes, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-linux-x64.rpm'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /Not supported Operation System, please use it on windows, linux or solaris host/)
    end

  end

  context 'With attributes and extra source_x64_file, on a linux platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.7.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-7u75-solaris-i586.tar.gz'
        node.set['fmw_jdk']['source_x64_file'] = '/software/jdk-7u75-solaris-x64.tar.gz'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /source_x64_file is only used in solaris for installing JDK x64 extension/)
    end

  end

  context 'With attributes and extra source_x64_file, on a Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11') do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.7.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-7u75-solaris-i586.tar.gz'
        node.set['fmw_jdk']['source_x64_file'] = '/software/jdk-7u75-solaris-x64.tar.gz'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to install_fmw_jdk_jdk('/usr/java/jdk1.7.0_XX').with(
        java_home_dir:       '/usr/java/jdk1.7.0_XX',
        source_file:         '/software/jdk-7u75-solaris-i586.tar.gz',
        source_x64_file:     '/software/jdk-7u75-solaris-x64.tar.gz'
      )
    end

  end

  context 'With attributes, rpm on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6', step_into: ['fmw_jdk_jdk_linux_rpm']) do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-linux-x64.rpm'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to install_fmw_jdk_jdk('/usr/java/jdk1.8.0_XX').with(
        java_home_dir:       '/usr/java/jdk1.8.0_XX',
        source_file:         '/software/jdk-8u40-linux-x64.rpm'
      )
    end

  end

  context 'With default attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw_jdk']['xxxx'] = '/xxx'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /fmw attributes cannot be empty/)
    end

  end

  context 'With default attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6')
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /fmw attributes cannot be empty/)
    end

  end

  context 'With attributes, rpm on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6', step_into: ['fmw_jdk_jdk_linux_rpm']) do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_XX'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /fmw_jdk attributes cannot be empty/)
    end

  end

  context 'With attributes, rpm on Debian platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'debian', version: '7.2') do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-linux-x64.rpm'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an error' do
      expect {chef_run}.to raise_error(RuntimeError, /please use the rpm source_file on rhel linux family OS/)
    end

  end

  context 'With attributes, tar.gz on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6', step_into: ['fmw_jdk_jdk_linux']) do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-linux-x64.tar.gz'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to install_fmw_jdk_jdk('/usr/java/jdk1.8.0_XX').with(
        java_home_dir:       '/usr/java/jdk1.8.0_XX',
        source_file:         '/software/jdk-8u40-linux-x64.tar.gz'
      )
      expect(chef_run).to create_directory('/usr/java/jdk1.8.0_XX').with(
        owner:  'root',
        group:  'root',
        mode: '0755',
        recursive: true
      )
      expect(chef_run).to run_execute('Unpack JDK').with(command: 'tar xzvf /software/jdk-8u40-linux-x64.tar.gz --directory /usr/java')
      expect(chef_run).to run_execute('alternatives java').with(command: 'alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_XX/bin/java 1')
      expect(chef_run).to run_execute('alternatives javac').with(command: 'alternatives --install /usr/bin/javac javac /usr/java/jdk1.8.0_XX/bin/javac 1')
      expect(chef_run).to run_execute('alternatives keytool').with(command: 'alternatives --install /usr/bin/keytool keytool /usr/java/jdk1.8.0_XX/bin/keytool 1')
      expect(chef_run).to run_execute('alternatives javaws').with(command: 'alternatives --install /usr/bin/javaws javaws /usr/java/jdk1.8.0_XX/bin/javaws 1')

      expect(chef_run).to create_directory('/usr/java/jdk1.8.0_XX').with(
        owner:  'root',
        group:  'root',
        mode: '0755'
      )

      expect(chef_run).to run_execute('chown java_home_dir').with(command: 'chown -R root:root /usr/java/jdk1.8.0_XX')
    end

  end

  context 'Without required source_file attribute, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_XX'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an validation exception' do
      expect {chef_run}.to raise_error(RuntimeError, /fmw_jdk attributes cannot be empty/)
    end

  end

  context 'Without required java_home_dir attribute, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-linux-x64.rpm'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an validation exception' do
      expect {chef_run}.to raise_error(RuntimeError, /fmw attributes cannot be empty/)
    end

  end

  context 'With wrong source file, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-linux-x64.exe'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an validation exception' do
      expect {chef_run}.to raise_error(RuntimeError, /Unknown source_file extension for linux, please use a rpm or tar.gz file/)
    end

  end

  context 'With attributes, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2', step_into: ['fmw_jdk_jdk_windows']) do |node|
        node.set['fmw']['java_home_dir'] = 'c:/program files/java/jdk1.8.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-windows-x64.exe'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to install_fmw_jdk_jdk('c:/program files/java/jdk1.8.0_XX').with(
        java_home_dir:       'c:/program files/java/jdk1.8.0_XX',
        source_file:         '/software/jdk-8u40-windows-x64.exe'
      )
      expect(chef_run).to create_directory('/vagrant/chef/cookbooks/fmw_jdk/c:/program files/java')
      expect(chef_run).to run_execute('Install JDK').with(command: '/software/jdk-8u40-windows-x64.exe /s ADDLOCAL="ToolsFeature" INSTALLDIR=c:\\program files\\java\\jdk1.8.0_XX')
    end
  end

  context 'With wrong source file, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2') do |node|
        node.set['fmw']['java_home_dir'] = 'c:/program files/java/jdk1.8.0_XX'
        node.set['fmw_jdk']['source_file'] = 'c:/temp/jdk-8u40-linux-x64.rpm'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an validation exception' do
      expect {chef_run}.to raise_error(Chef::Exceptions::ValidationFailed, /Option source_file\'s value c:\/temp\/jdk-8u40-linux-x64.rpm source should have a valid JDK extension/)
    end
  end

  context 'With attributes, tar.gz on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11', step_into: ['fmw_jdk_jdk_solaris']) do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-solaris-x64.tar.gz'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to install_fmw_jdk_jdk('/usr/java/jdk1.8.0_XX').with(
        java_home_dir:       '/usr/java/jdk1.8.0_XX',
        source_file:         '/software/jdk-8u40-solaris-x64.tar.gz'
      )

      expect(chef_run).to create_directory('/usr/java/jdk1.8.0_XX').with(
        owner:  'root',
        group:  'bin',
        mode: '0755',
        recursive: true
      )
      expect(chef_run).to run_execute('uncompress JDK').with(
        command: 'gzip -dc /software/jdk-8u40-solaris-x64.tar.gz | tar xf -',
        cwd: '/usr/java'
      )

      expect(chef_run).to create_link('/usr/bin/java').with(to: '/usr/java/jdk1.8.0_XX/bin/java')
      expect(chef_run).to create_link('/usr/bin/javac').with(to: '/usr/java/jdk1.8.0_XX/bin/javac')
      expect(chef_run).to create_link('/usr/bin/javaws').with(to: '/usr/java/jdk1.8.0_XX/bin/javaws')
      expect(chef_run).to create_link('/usr/bin/keytool').with(to: '/usr/java/jdk1.8.0_XX/bin/keytool')
      expect(chef_run).to create_link('/usr/java').with(to: '/usr/java/jdk1.8.0_XX')
      expect(chef_run).to create_link('/usr/jdk/latest').with(to: '/usr/java/jdk1.8.0_XX')

      expect(chef_run).to run_execute('chown java_home_dir').with(command: 'chown -R root:bin /usr/java/jdk1.8.0_XX')
    end

  end

  context 'With attributes, JDK 7 tar.gz on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11', step_into: ['fmw_jdk_jdk_solaris']) do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.7.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-7u75-solaris-i586.tar.gz'
        node.set['fmw_jdk']['source_x64_file'] = '/software/jdk-7u75-solaris-x64.tar.gz'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to install_fmw_jdk_jdk('/usr/java/jdk1.7.0_XX').with(
        java_home_dir:       '/usr/java/jdk1.7.0_XX',
        source_file:         '/software/jdk-7u75-solaris-i586.tar.gz',
        source_x64_file:     '/software/jdk-7u75-solaris-x64.tar.gz'
      )

      expect(chef_run).to create_directory('/usr/java/jdk1.7.0_XX').with(
        owner:  'root',
        group:  'bin',
        mode: '0755',
        recursive: true
      )
      expect(chef_run).to run_execute('uncompress JDK').with(
        command: 'gzip -dc /software/jdk-7u75-solaris-i586.tar.gz | tar xf -',
        cwd: '/usr/java'
      )

      expect(chef_run).to run_execute('uncompress JDK x64 extensions').with(
        command: 'gzip -dc /software/jdk-7u75-solaris-x64.tar.gz | tar xf -',
        cwd: '/usr/java'
      )

      expect(chef_run).to create_link('/usr/bin/java').with(to: '/usr/java/jdk1.7.0_XX/bin/java')
      expect(chef_run).to create_link('/usr/bin/javac').with(to: '/usr/java/jdk1.7.0_XX/bin/javac')
      expect(chef_run).to create_link('/usr/bin/javaws').with(to: '/usr/java/jdk1.7.0_XX/bin/javaws')
      expect(chef_run).to create_link('/usr/bin/keytool').with(to: '/usr/java/jdk1.7.0_XX/bin/keytool')
      expect(chef_run).to create_link('/usr/java').with(to: '/usr/java/jdk1.7.0_XX')
      expect(chef_run).to create_link('/usr/jdk/latest').with(to: '/usr/java/jdk1.7.0_XX')

      expect(chef_run).to run_execute('chown java_home_dir').with(command: 'chown -R root:bin /usr/java/jdk1.7.0_XX')
    end

  end

  context 'With attributes, tar.Z on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11', step_into: ['fmw_jdk_jdk_solaris_z']) do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-solaris-x64.tar.Z'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to install_fmw_jdk_jdk('/usr/java/jdk1.8.0_XX')

      expect(chef_run).to create_directory('/tmp/java').with( mode: '0775' )

      expect(chef_run).to create_cookbook_file('/tmp/java/admin.rsp').with(
        source: 'solaris_admin.rsp',
        mode: '0775'
      )

      expect(chef_run).to run_execute('uncompress JDK SVR4 packages').with(
        command: 'zcat /software/jdk-8u40-solaris-x64.tar.Z|tar -xvpf -',
        cwd: '/tmp/java'
      )

      expect(chef_run).to run_execute('install JDK SVR4 packages').with(command: 'pkgadd -a /tmp/java/admin.rsp -d /tmp/java SUNWj8rt')
    end

  end

  context 'With attributes, JDK 7 tar.Z on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11', step_into: ['fmw_jdk_jdk_solaris_z']) do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.7.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-7u75-solaris-i586.tar.Z'
        node.set['fmw_jdk']['source_x64_file'] = '/software/jdk-7u75-solaris-x64.tar.Z'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to install_fmw_jdk_jdk('/usr/java/jdk1.7.0_XX')

      expect(chef_run).to create_directory('/tmp/java').with( mode: '0775' )

      expect(chef_run).to create_cookbook_file('/tmp/java/admin.rsp').with(
        source: 'solaris_admin.rsp',
        mode: '0775'
      )

      expect(chef_run).to run_execute('uncompress JDK SVR4 packages').with(
        command: 'zcat /software/jdk-7u75-solaris-i586.tar.Z|tar -xvpf -',
        cwd: '/tmp/java'
      )

      expect(chef_run).to run_execute('install JDK SVR4 packages').with(command: 'pkgadd -a /tmp/java/admin.rsp -d /tmp/java SUNWj7rt')

      expect(chef_run).to run_execute('uncompress JDK x64 SVR4 packages').with(
        command: 'zcat /software/jdk-7u75-solaris-x64.tar.Z|tar -xvpf -',
        cwd: '/tmp/java'
      )

      expect(chef_run).to run_execute('install JDK x64 SVR4 packages').with(command: 'pkgadd -a /tmp/java/admin.rsp -d /tmp/java SUNWj7rtx')

    end

  end

  context 'With attributes, rpm on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11') do |node|
        node.set['fmw']['java_home_dir'] = '/usr/java/jdk1.8.0_XX'
        node.set['fmw_jdk']['source_file'] = '/software/jdk-8u40-solaris-x64.rpm'
      end
      runner.converge(described_recipe)
    end

    it 'converges with an validation exception' do
      expect {chef_run}.to raise_error(RuntimeError, /Unknown source_file extension for solaris, please use a tar.gz or tar.Z SVR4 file/)
    end

  end

end
