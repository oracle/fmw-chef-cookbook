#
# Cookbook Name:: fmw_jdk
# Recipe:: rng_service
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

unless ['linux'].include?(node['os'])
  # only necessary for linux VM
  return
end

if (node['platform_family'] == 'rhel' and node['platform_version'] < '6.0')
  return
end

package 'rng-tools'

if VERSION.start_with? '11.'
  ruby_block "loading for chef 11 jdk rng_service" do
    block do
      if node['platform_family'] == 'rhel'
        res = Chef::Resource::Chef::Resource::FmwJdkRngServiceRedhat.new( 'rng service', run_context ) if  node['platform_version'] < '7.0'
        res = Chef::Resource::Chef::Resource::FmwJdkRngServiceRedhat7.new( 'rng service', run_context ) if node['platform_version'] >= '7.0'
      else
        res = Chef::Resource::Chef::Resource::FmwJdkRngServiceDebian.new( 'rng service', run_context )
      end
      res.run_action :configure
    end
  end
else
  fmw_jdk_rng_service 'rng service'
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
