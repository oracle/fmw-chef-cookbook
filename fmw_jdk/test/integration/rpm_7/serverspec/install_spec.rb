require 'spec_helper'

describe 'fmw_jdk::install' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  describe file('/usr/java/jdk1.7.0_75') do
    it { should be_directory }
    it { should be_owned_by 'root' }
  end

  describe file('/usr/java/jdk1.7.0_75/bin/java') do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_executable }
  end

end