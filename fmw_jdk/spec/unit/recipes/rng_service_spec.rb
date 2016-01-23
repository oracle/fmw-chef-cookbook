#
# Cookbook Name:: fmw_jdk
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_jdk::rng_service' do

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end

  context 'When all attributes are default, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end

  context 'When all attributes are default, on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end

  context 'With attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to install_package('rng-tools')
      expect(chef_run).to configure_fmw_jdk_rng_service('rng service')
    end

  end

  context 'With attributes, on centos Linux 7 platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.0.1406', step_into: ['fmw_jdk_rng_service_redhat_7'])
      runner.converge(described_recipe)
    end

    before do
      stub_command("grep 'ExecStart=/sbin/rngd -r /dev/urandom -o /dev/random -f' /lib/systemd/system/rngd.service").and_return(false)
    end

    it 'converges successfully' do
      expect(chef_run).to install_package('rng-tools')
      expect(chef_run).to configure_fmw_jdk_rng_service('rng service')

      resource = chef_run.execute('systemctl-daemon-reload')
      expect(resource).to do_nothing

      resource2 = chef_run.service('rngd')
      expect(resource2).to do_nothing

      expect(chef_run).to run_execute('sed rngd.service')
      resource3 = chef_run.execute('sed rngd.service')
      expect(resource3).to notify('service[rngd]').to(:enable).immediately
      expect(resource3).to notify('service[rngd]').to(:restart).immediately
      expect(resource3).to notify('execute[systemctl-daemon-reload]').to(:run).immediately

    end

  end

  context 'With attributes, on Oracle Linux platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'oracle', version: '6.5', step_into: ['fmw_jdk_rng_service_redhat'])
      runner.converge(described_recipe)
    end

    before do
      stub_command("grep '^EXTRAOPTIONS=\"-r /dev/urandom -o /dev/random -b\"' /etc/sysconfig/rngd").and_return(false)
    end

    it 'converges successfully' do
      expect(chef_run).to install_package('rng-tools')
      expect(chef_run).to configure_fmw_jdk_rng_service('rng service')

      resource = chef_run.execute('chkconfig rngd')
      expect(resource).to do_nothing

      resource2 = chef_run.service('rngd')
      expect(resource2).to do_nothing

      expect(chef_run).to run_execute('sed rngd.service')
      resource3 = chef_run.execute('sed rngd.service')
      expect(resource3).to notify('service[rngd]').to(:enable).immediately
      expect(resource3).to notify('service[rngd]').to(:restart).immediately
      expect(resource3).to notify('execute[chkconfig rngd]').to(:run).immediately

    end

  end

  context 'With attributes, on Debian platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'debian', version: '7.2', step_into: ['fmw_jdk_rng_service_debian'])
      runner.converge(described_recipe)
    end

    before do
       stub_command("grep '^HRNGDEVICE=/dev/urandom' /etc/default/rng-tools").and_return(false)
    end

    it 'converges successfully' do
      expect(chef_run).to install_package('rng-tools')
      expect(chef_run).to configure_fmw_jdk_rng_service('rng service')

      resource2 = chef_run.service('rng-tools')
      expect(resource2).to do_nothing

      expect(chef_run).to run_execute('sed rng-tools')
      resource3 = chef_run.execute('sed rng-tools')
      expect(resource3).to notify('service[rng-tools]').to(:enable).immediately
      expect(resource3).to notify('service[rng-tools]').to(:restart).immediately

    end

  end

end
