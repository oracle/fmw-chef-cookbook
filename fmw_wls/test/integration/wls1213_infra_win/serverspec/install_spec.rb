require 'spec_helper'

describe 'fmw_wls::install' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  describe file('c:\\java\\jdk1.7.0_75') do
    it { should be_directory }
  end

  describe file('c:\\java\\jdk1.7.0_75\\bin\\java.exe') do
    it { should be_file }
  end

  describe file('C:/Users/vagrant/AppData/Local/temp/wls_12c.rsp') do
    it { should be_file }
    it { should contain 'INSTALL_TYPE=Fusion Middleware Infrastructure' }
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

end