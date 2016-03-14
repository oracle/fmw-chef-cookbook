#
# Cookbook Name:: fmw_jdk
# Recipe:: install
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

unless ['windows', 'linux', 'solaris2'].include?(node['os'])
  fail 'Not supported Operation System, please use it on windows, linux or solaris host'
end

fail 'fmw attributes cannot be empty' unless node.attribute?('fmw')
fail 'fmw_jdk attributes cannot be empty' unless node.attribute?('fmw_jdk')
fail 'source_file parameter cannot be empty' unless node['fmw_jdk'].attribute?('source_file')
fail 'source_file parameter cannot be empty' if node['fmw_jdk']['source_file'].nil?

unless node['fmw_jdk']['source_x64_file'].nil?
  fail 'source_x64_file is only used in solaris for installing JDK x64 extension' if ['windows', 'linux'].include?(node['os'])
end

# linux
if node['os'].include?('linux')

  if node['fmw_jdk']['source_file'].include?('rpm')
    node.default['fmw_jdk']['install_type'] = 'rpm'
    fail 'please use the rpm source_file on rhel linux family OS' unless node['platform_family'].include?('rhel')

  elsif node['fmw_jdk']['source_file'].include?('tar.gz')
    node.default['fmw_jdk']['install_type'] = 'tar.gz'

  else
    fail 'Unknown source_file extension for linux, please use a rpm or tar.gz file'
  end
# solaris
elsif node['os'].include?('solaris2')

  if node['fmw_jdk']['source_file'].include?('tar.Z')
    node.default['fmw_jdk']['install_type'] = 'tar.Z'

  elsif node['fmw_jdk']['source_file'].include?('tar.gz')
    node.default['fmw_jdk']['install_type'] = 'tar.gz'

  else
    fail 'Unknown source_file extension for solaris, please use a tar.gz or tar.Z SVR4 file'
  end
end

if VERSION.start_with? '11.'
  ruby_block "loading for chef 11 jdk install" do
    block do
      if node['os'].include?('linux')
        res = Chef::Resource::Chef::Resource::FmwJdkJdkLinux.new( node['fmw']['java_home_dir'], run_context ) if node['fmw_jdk']['install_type'] == 'tar.gz'
        res = Chef::Resource::Chef::Resource::FmwJdkJdkLinuxRpm.new( node['fmw']['java_home_dir'], run_context ) if node['fmw_jdk']['install_type'] == 'rpm'
      elsif node['os'].include?('solaris2')
        res = Chef::Resource::Chef::Resource::FmwJdkJdkSolaris.new( node['fmw']['java_home_dir'], run_context ) if node['fmwjdk']['install_type'] == 'tar.gz'
        res = Chef::Resource::Chef::Resource::FmwJdkJdkSolarisZ.new( node['fmw']['java_home_dir'], run_context ) if node['fmwjdk']['install_type'] == 'tar.Z'
      else
        res = Chef::Resource::Chef::Resource::FmwJdkJdkWindows.new( node['fmw']['java_home_dir'], run_context )
      end
      res.java_home_dir   node['fmw']['java_home_dir']
      res.source_file     node['fmw_jdk']['source_file']
      res.source_x64_file node['fmw_jdk']['source_x64_file'] if node['os'].include?('solaris2')
      res.run_action      :install
    end
  end
else
  fmw_jdk_jdk node['fmw']['java_home_dir'] do
    action          :install
    java_home_dir   node['fmw']['java_home_dir']
    source_file     node['fmw_jdk']['source_file']
    source_x64_file node['fmw_jdk']['source_x64_file'] if node['os'].include?('solaris2')
  end
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
