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

fmw_jdk_rng_service 'rng service'

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
