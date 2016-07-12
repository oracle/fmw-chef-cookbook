#
# Cookbook Name:: fmw_opatch
# Recipe:: soa_suite
#
# Copyright 2015 Oracle. All Rights Reserved
#
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

include_recipe 'fmw_inst::soa_suite'

fail 'fmw_opatch attributes cannot be empty' unless node.attribute?('fmw_opatch')
fail 'source_file parameter cannot be empty' unless node['fmw_opatch'].attribute?('soa_suite_source_file')
fail 'patch_id parameter cannot be empty' unless node['fmw_opatch'].attribute?('soa_suite_patch_id')

if ['12.2.1', '12.2.1.1', '12.1.3'].include?(node['fmw']['version'])
  fmw_oracle_home = node['fmw']['middleware_home_dir']
elsif ['10.3.6'].include?(node['fmw']['version'])
  if node['os'].include?('windows')
    fmw_oracle_home = node['fmw']['middleware_home_dir'] + '\\Oracle_SOA1'
  else
    fmw_oracle_home = node['fmw']['middleware_home_dir'] + '/Oracle_SOA1'
  end
end


if VERSION.start_with? '11.'
  ruby_block "loading for chef 11 opatch service bus extract" do
    block do
      if node['os'].include?('windows')
        res = Chef::Resource::Chef::Resource::FmwOpatchFmwExtractWindows.new(node['fmw_opatch']['soa_suite_patch_id'], run_context )
      else
        res = Chef::Resource::Chef::Resource::FmwOpatchFmwExtract.new(node['fmw_opatch']['soa_suite_patch_id'], run_context )
      end
      res.source_file         node['fmw_opatch']['soa_suite_source_file']
      res.os_user             node['fmw']['os_user']             if ['solaris2', 'linux'].include?(node['os'])
      res.os_group            node['fmw']['os_group']            if ['solaris2', 'linux'].include?(node['os'])
      res.tmp_dir             node['fmw']['tmp_dir']
      res.middleware_home_dir node['fmw']['middleware_home_dir'] if node['os'].include?('windows')
      res.version             node['fmw']['version']             if node['os'].include?('windows')
      res.run_action          :extract
    end
  end
  ruby_block "loading for chef 11 opatch service bus apply" do
    block do
      if node['os'].include?('windows')
        res2 = Chef::Resource::Chef::Resource::FmwOpatchOpatchWindows.new(node['fmw_opatch']['soa_suite_patch_id'], run_context )
      else
        res2 = Chef::Resource::Chef::Resource::FmwOpatchOpatch.new(node['fmw_opatch']['soa_suite_patch_id'], run_context )
      end
      res2.patch_id            node['fmw_opatch']['soa_suite_patch_id']
      res2.oracle_home_dir     fmw_oracle_home
      res2.java_home_dir       node['fmw']['java_home_dir']
      res2.orainst_dir         node['fmw']['orainst_dir']         if ['solaris2', 'linux'].include?(node['os'])
      res2.os_user             node['fmw']['os_user']             if ['solaris2', 'linux'].include?(node['os'])
      res2.os_group            node['fmw']['os_group']            if ['solaris2', 'linux'].include?(node['os'])
      res2.tmp_dir             node['fmw']['tmp_dir']
      res2.run_action          :apply
    end
  end
else
  fmw_opatch_fmw_extract node['fmw_opatch']['soa_suite_patch_id'] do
    action              :extract
    source_file         node['fmw_opatch']['soa_suite_source_file']
    os_user             node['fmw']['os_user']             if ['solaris2', 'linux'].include?(node['os'])
    os_group            node['fmw']['os_group']            if ['solaris2', 'linux'].include?(node['os'])
    tmp_dir             node['fmw']['tmp_dir']
    middleware_home_dir node['fmw']['middleware_home_dir'] if node['os'].include?('windows')
    version             node['fmw']['version']             if node['os'].include?('windows')
  end

  fmw_opatch_opatch node['fmw_opatch']['soa_suite_patch_id'] do
    action              :apply
    patch_id            node['fmw_opatch']['soa_suite_patch_id']
    oracle_home_dir     fmw_oracle_home
    java_home_dir       node['fmw']['java_home_dir']
    orainst_dir         node['fmw']['orainst_dir']         if ['solaris2', 'linux'].include?(node['os'])
    os_user             node['fmw']['os_user']             if ['solaris2', 'linux'].include?(node['os'])
    os_group            node['fmw']['os_group']            if ['solaris2', 'linux'].include?(node['os'])
    tmp_dir             node['fmw']['tmp_dir']
  end
end
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
