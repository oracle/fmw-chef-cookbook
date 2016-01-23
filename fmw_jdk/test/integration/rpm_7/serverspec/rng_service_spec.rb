require 'spec_helper'

describe 'fmw_jdk::rng_service' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

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

end