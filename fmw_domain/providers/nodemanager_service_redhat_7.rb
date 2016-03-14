#
# Cookbook Name:: fmw_domain
# Provider:: nodemanager_service
#
# Copyright 2015 Oracle. All Rights Reserved
#
# nodemanager_service provider for RedHat family 7
if respond_to?(:provides)
  provides :fmw_domain_nodemanager_service, os: 'linux', platform_family: 'rhel' do |node|
    node['platform_version'] >= '7.0'
  end
end

def whyrun_supported?
  true
end

def load_current_resource
  Chef::Log.info('nodemanager_service provider, nodemanager_service_redhat provider load current resource')
  @current_resource ||= Chef::Resource::FmwDomainNodemanagerServiceRedhat7.new(new_resource.name)
  @current_resource.user_home_dir(@new_resource.user_home_dir)
  @current_resource.os_user(@new_resource.os_user)
  @current_resource
end

# Configure the nodemanager service on a RedHat family 7 host
action :configure do
  Chef::Log.info("#{@new_resource} fired the configure action")
  converge_by("configure resource #{ @new_resource }") do

    execute 'systemctl-daemon-reload' do
      command '/bin/systemctl --system daemon-reload'
      action :nothing
    end

    execute 'systemctl-enable' do
      command "/bin/systemctl enable #{new_resource.name}.service"
      not_if "/bin/systemctl list-units --type service --all | /bin/grep '#{new_resource.name}.service'"
      action :nothing
    end

    template "/lib/systemd/system/#{new_resource.name}.service" do
      source 'nodemanager/systemd'
      mode 0755
      variables(script_name:    new_resource.name,
                user_home_dir:  new_resource.user_home_dir,
                os_user:        new_resource.os_user)
      notifies :run, 'execute[systemctl-daemon-reload]', :immediately
      notifies :run, 'execute[systemctl-enable]', :immediately
      notifies :enable, "service[#{new_resource.name}.service]", :immediately
      notifies :restart, "service[#{new_resource.name}.service]", :immediately
    end

    service "#{new_resource.name}.service" do
      action :start
      provider Chef::Provider::Service::Systemd
      supports status: true, restart: true, reload: true
    end
  end
end
