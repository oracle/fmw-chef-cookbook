require 'spec_helper'

describe 'fmw_domain::domain' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  describe file('C:/java/jdk1.8.0_40') do
    it { should be_directory }
  end

  describe file('C:/java/jdk1.8.0_40/bin/java.exe') do
    it { should be_file }
  end

  describe file('C:/Users/vagrant/AppData/Local/temp/wls_12c.rsp') do
    it { should be_file }
    it { should contain 'INSTALL_TYPE=WebLogic Server' }
  end

  describe file('C:\\Program Files\\Oracle\\Inventory') do
    it { should be_directory }
  end

  describe file('C:/oracle/middleware_1213') do
    it { should be_directory }
  end

  describe file('C:/oracle/middleware_1213/oracle_common/common/bin/wlst.cmd') do
    it { should be_file }
  end

  describe file('C:/oracle/middleware_1213/user_projects/domains/base') do
    it { should be_directory }
  end

  describe service('Oracle Weblogic base NodeManager (c_oracle_MIDDLE~1_wlserver)') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(5556) do
    it { should be_listening }
  end

  describe port(7001) do
    it { should be_listening }
  end

end