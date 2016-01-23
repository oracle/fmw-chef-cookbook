#
# Cookbook Name:: fmw_jdk
# Provider:: rng_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
# rng service provider for RedHat 7 family
provides :fmw_jdk_rng_service, os: 'linux', platform_family: 'rhel' do |node|
  node['platform_version'] >= '7.0'
end

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('rng_service provider, rng_service_redhat_7 provider load current resource')
  @current_resource ||= Chef::Resource::FmwJdkRngServiceRedhat7.new(new_resource.name)
  @current_resource
end

# Installs the rng package and the rngd services on a RedHat 7 family host
action :configure do
  Chef::Log.info("#{@new_resource} fired the configure action")
  converge_by("configure resource #{ @new_resource }") do
    # reload after a change in /lib/systemd/system/rngd.service
    execute 'systemctl-daemon-reload' do
      command '/bin/systemctl --system daemon-reload'
      action :nothing
    end

    # systemctl status rngd.service
    service 'rngd' do
      action :nothing
      provider Chef::Provider::Service::Systemd
      supports status: true, restart: true, reload: true
    end

    # /lib/systemd/system/rngd.service
    # original ExecStart=/sbin/rngd -f
    # changed: ExecStart=/sbin/rngd -r /dev/urandom -o /dev/random -f
    execute 'sed rngd.service' do
      command "sed -i -e's/ExecStart=\\/sbin\\/rngd -f/ExecStart=\\/sbin\\/rngd -r \\/dev\\/urandom -o \\/dev\\/random -f/g' /lib/systemd/system/rngd.service"
      not_if "grep 'ExecStart=/sbin/rngd -r /dev/urandom -o /dev/random -f' /lib/systemd/system/rngd.service"
      notifies :run, 'execute[systemctl-daemon-reload]', :immediately
      notifies :enable, 'service[rngd]', :immediately
      notifies :restart, 'service[rngd]', :immediately
    end
  end
end
