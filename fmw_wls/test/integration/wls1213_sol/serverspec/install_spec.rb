require 'spec_helper'

describe 'fmw_wls::install' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  describe file('/usr/jdk/instances/jdk1.8.0_40') do
    it { should be_directory }
    it { should be_owned_by 'root' }
  end

  describe file('/usr/jdk/instances/jdk1.8.0_40/bin/java') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_executable }
  end

  describe file('/usr/bin/java') do
    it { should be_symlink }
    it { should be_linked_to '/usr/jdk/instances/jdk1.8.0_40/bin/java' }
  end

  describe group('oinstall') do
    it { should exist }
  end

  describe user('oracle') do
    it { should belong_to_group 'oinstall' }
    it { should have_home_directory '/export/home/oracle' }
    it { should have_login_shell '/bin/bash' }
  end

  describe file('/var/opt/oracle/oraInst.loc') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_readable.by('others') }
    # it { should contain 'inventory_loc=/export/home/oracle/oraInventory' }
    # it { should contain 'inst_group=oinstall' }
  end

  describe file('/var/tmp/wls_12c.rsp') do
    it { should be_file }
    # it { should contain 'ORACLE_HOME=/opt/oracle/middleware_1213' }
    # it { should contain 'INSTALL_TYPE=Fusion Middleware Infrastructure' }
  end

  describe file('/export/home/oracle/oraInventory') do
    it { should be_directory }
    it { should be_owned_by 'oracle' }
    it { should be_grouped_into 'oinstall' }
  end

  describe file('/opt/oracle/middleware_1213') do
    it { should be_directory }
    it { should be_owned_by 'oracle' }
    it { should be_grouped_into 'oinstall' }
  end

  describe file('/opt/oracle/middleware_1213/oracle_common/common/bin/wlst.sh') do
    it { should be_file }
    it { should be_owned_by 'oracle' }
    it { should be_grouped_into 'oinstall' }
    it { should be_executable }
  end

end