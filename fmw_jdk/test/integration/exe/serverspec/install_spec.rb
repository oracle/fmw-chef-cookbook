require 'spec_helper'

describe 'fmw_jdk::install' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  describe file('C:/java/jdk1.8.0_40') do
    it { should be_directory }
  end

  describe file('C:/java/jdk1.8.0_40/bin/java.exe') do
    it { should be_file }
  end

end