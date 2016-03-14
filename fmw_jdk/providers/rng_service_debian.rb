#
# Cookbook Name:: fmw_jdk
# Provider:: rng_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
# rng service provider for Debian family
provides :fmw_jdk_rng_service, os: 'linux', platform_family: 'debian' if respond_to?(:provides)

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('rng_service provider, rng_service_debian provider load current resource')
  @current_resource ||= Chef::Resource::FmwJdkRngServiceDebian.new(new_resource.name)
  @current_resource
end

# Installs the rng package and the rngd services on a Debian family host
action :configure do
  Chef::Log.info("#{@new_resource} fired the configure action")
  converge_by("configure resource #{ @new_resource }") do
    # service rngd status
    service 'rng-tools' do
      action :nothing
      supports status: true, restart: true, reload: true
    end

    # /etc/default/rng-tools
    # original EXTRAOPTIONS=""
    # changed: EXTRAOPTIONS="-r /dev/urandom -o /dev/random -b"
    execute 'sed rng-tools' do
      command "sed -i -e's/#HRNGDEVICE=\\/dev\\/null/HRNGDEVICE=\\/dev\\/urandom/g' /etc/default/rng-tools"
      not_if "grep '^HRNGDEVICE=/dev/urandom' /etc/default/rng-tools"
      notifies :enable, 'service[rng-tools]', :immediately
      notifies :restart, 'service[rng-tools]', :immediately
    end
  end
end
