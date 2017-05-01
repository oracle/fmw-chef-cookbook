require 'spec_helper'

describe 'fmw_inst::install' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  describe file('c:\\java\\jdk1.7.0_79') do
    it { should be_directory }
  end

  describe file('c:\\java\\jdk1.7.0_79\\bin\\java.exe') do
    it { should be_file }
  end

  describe file('C:/Users/vagrant/AppData/Local/temp/wls_11g.rsp') do
    it { should be_file }
  end

  describe file('C:\\Program Files\\Oracle\\Inventory') do
    it { should be_directory }
  end

  describe file('C:/oracle/middleware_1036') do
    it { should be_directory }
  end

  describe file('C:/oracle/middleware_1036/wlserver_10.3/common/bin/wlst.cmd') do
    it { should be_file }
  end

  describe file('C:/oracle/middleware_1036/Oracle_OSB1') do
    it { should be_directory }
  end

  describe file('C:/oracle/middleware_1036/Oracle_SOA1') do
    it { should be_directory }
  end

end
