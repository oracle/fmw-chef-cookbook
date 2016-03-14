#
# Cookbook Name:: fmw_jdk
# Provider:: rng_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
# rng service provider for RedHat family
if respond_to?(:provides)
  provides :fmw_jdk_rng_service, os: 'linux', platform_family: 'rhel' do |node|
    node['platform_version'] < '7.0'
  end
end

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('rng_service provider, rng_service_redhat provider load current resource')
  @current_resource ||= Chef::Resource::FmwJdkRngServiceRedhat.new(new_resource.name)
  @current_resource
end

# Installs the rng package and the rngd services on a RedHat family host
action :configure do
  Chef::Log.info("#{@new_resource} fired the configure action")
  converge_by("configure resource #{ @new_resource }") do
    # service rngd status
    service 'rngd' do
      action :nothing
      supports status: true, restart: true, reload: true
    end

    # add service for auto start
    execute 'chkconfig rngd' do
      command 'chkconfig --add rngd'
      action :nothing
    end

    # /etc/sysconfig/rngd
    # original EXTRAOPTIONS=""
    # changed: EXTRAOPTIONS="-r /dev/urandom -o /dev/random -b"
    execute 'sed rngd.service' do
      command "sed -i -e's/EXTRAOPTIONS=\"\"/EXTRAOPTIONS=\"-r \\/dev\\/urandom -o \\/dev\\/random -b\"/g' /etc/sysconfig/rngd"
      not_if "grep '^EXTRAOPTIONS=\"-r /dev/urandom -o /dev/random -b\"' /etc/sysconfig/rngd"
      notifies :enable, 'service[rngd]', :immediately
      notifies :restart, 'service[rngd]', :immediately
      notifies :run, 'execute[chkconfig rngd]', :immediately
    end
  end
end
