require 'spec_helper'

describe 'fmw_inst::install' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  describe file('/usr/java/jdk1.8.0_131') do
    it { should be_directory }
    it { should be_owned_by 'root' }
  end

  describe file('/usr/java/jdk1.8.0_131/bin/java') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_executable }
  end

  describe file('/usr/bin/java') do
    it { should be_symlink }
    it { should be_linked_to '/etc/alternatives/java' }
  end

  if ['redhat'].include?(os[:family]) and os[:release] >= '6.0'

    describe service('rngd') do
      it { should be_enabled }
      it { should be_running }
    end

  elsif ['debian'].include?(os[:family])

    describe service('rng-tools') do
      it { should be_enabled }
    end

    describe service('rngd') do
      it { should be_running }
    end

  end

  describe group('oinstall') do
    it { should exist }
  end

  describe user('oracle') do
    it { should belong_to_group 'oinstall' }
    it { should have_home_directory '/home/oracle' }
    it { should have_login_shell '/bin/bash' }
  end

  describe file('/etc/oraInst.loc') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_readable.by('others') }
    it { should contain 'inventory_loc=/home/oracle/oraInventory' }
    it { should contain 'inst_group=oinstall' }
  end

  describe file('/tmp/wls_12c.rsp') do
    it { should be_file }
    it { should contain 'ORACLE_HOME=/opt/oracle/middleware_1221' }
    it { should contain 'INSTALL_TYPE=Fusion Middleware Infrastructure' }
  end

  describe file('/home/oracle/oraInventory') do
    it { should be_directory }
    it { should be_owned_by 'oracle' }
    it { should be_grouped_into 'oinstall' }
  end

  describe file('/opt/oracle/middleware_1221') do
    it { should be_directory }
    it { should be_owned_by 'oracle' }
    it { should be_grouped_into 'oinstall' }
  end

  describe file('/opt/oracle/middleware_1221/oracle_common/common/bin/wlst.sh') do
    it { should be_file }
    it { should be_owned_by 'oracle' }
    it { should be_grouped_into 'oinstall' }
    it { should be_executable }
  end

  describe file('/opt/oracle/middleware_1221/oracle_common/bin/rcu') do
    it { should be_file }
    it { should be_owned_by 'oracle' }
    it { should be_grouped_into 'oinstall' }
    it { should be_executable }
  end

  describe file('/opt/oracle/middleware_1221/soa/bin') do
    it { should be_directory }
    it { should be_owned_by 'oracle' }
    it { should be_grouped_into 'oinstall' }
  end

  describe file('/opt/oracle/middleware_1221/osb/bin') do
    it { should be_directory }
    it { should be_owned_by 'oracle' }
    it { should be_grouped_into 'oinstall' }
  end

end
