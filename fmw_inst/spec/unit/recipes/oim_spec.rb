#
# Cookbook Name:: fmw_inst
# Spec:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'fmw_inst::oim' do

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
        node.set['fmw']['java_home_dir']   = '/usr/java/jdk1.7.0_75'
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
        node.set['fmw_wls']['source_file']   = '/software/wls1036_generic.jar'
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
        node.set['fmw']['version']                      = '10.3.6'
        node.set['oim']['version']                      = '11.1.2'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_inst']['source_file']             = '/software/fmw_ofm_iam_generic_11.1.2.3.0_Disk1_1of3.zip'
        node.set['fmw_inst']['source_2_file']           = '/software/fmw_ofm_iam_generic_11.1.2.3.0_Disk1_2of3.zip'
        node.set['fmw_inst']['source_3_file']           = '/software/fmw_ofm_iam_generic_11.1.2.3.0_Disk1_3of3.zip'
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
        node.set['fmw']['version']                      = '10.3.6'
        node.set['oim']['version']                      = '11.1.2'
        node.set['fmw']['middleware_home_dir']          = '/opt/oracle/middleware_xxx'
        node.set['fmw_jdk']['source_file']              = '/software/jdk-7u75-linux-x64.tar.gz'
        node.set['fmw_wls']['source_file']              = '/software/wls1036_generic.jar'
        node.set['fmw_inst']['source_file']             = '/software/fmw_ofm_iam_generic_11.1.2.3.0_Disk1_1of3.zip'
        node.set['fmw_inst']['source_2_file']           = '/software/fmw_ofm_iam_generic_11.1.2.3.0_Disk1_2of3.zip'
        node.set['fmw_inst']['source_3_file']           = '/software/fmw_ofm_iam_generic_11.1.2.3.0_Disk1_3of3.zip'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

  end




end
