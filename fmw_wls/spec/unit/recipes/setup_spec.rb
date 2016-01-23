#
# Cookbook Name:: fmw_wls
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_wls::setup' do

  context 'When all attributes are default, on Windows platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'windows', version: '2012R2')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end

  context 'When all attributes are default, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to create_group('oinstall')
      expect(chef_run).to create_user('oracle').with(gid: 'oinstall', home: '/home/oracle')
    end

  end

  context 'When custom attributes, on CentOS platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.6') do |node|
        node.set['fmw']['os_user'] = 'wls'
        node.set['fmw']['os_group'] = 'dba'
        node.set['fmw']['user_home_dir'] = '/aaa'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to create_group('dba')
      expect(chef_run).to create_user('wls').with(gid: 'dba', home: '/aaa/wls')
    end

  end

  context 'When all attributes are default, on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11')
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to create_group('oinstall')
      expect(chef_run).to create_user('oracle').with(gid: 'oinstall', home: '/export/home/oracle')
    end

  end

  context 'When all attributes are default, on Solaris platform' do

    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'solaris2', version: '5.11') do |node|
        node.set['fmw']['os_user'] = 'wls'
        node.set['fmw']['os_group'] = 'dba'
        node.set['fmw']['user_home_dir'] = '/aaa'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      expect(chef_run).to create_group('dba')
      expect(chef_run).to create_user('wls').with(gid: 'dba', home: '/aaa/wls')
    end

  end

end
