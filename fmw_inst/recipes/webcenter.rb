#
# Cookbook Name:: fmw_inst
# Recipe:: webcenter
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

include_recipe 'fmw_wls::install'

fail 'fmw_inst attributes cannot be empty' unless node.attribute?('fmw_inst')

if node['fmw'].nil?
   node.override['fmw']=Hash.new()
end

if !('typical'.casecmp(node['fmw']['install_type'].to_s)==0)
   node.override['fmw']['install_type']='typical'
end

if ['12.2.1', '12.2.1.1'].include?(node['fmw']['version'])
  fmw_template = 'fmw_12c.rsp'
  fmw_oracle_home = node['fmw']['middleware_home_dir'] + '/wcportal'
  option_array = []
  install_type = 'WebCenter Portal'

  if node['fmw']['version'] == '12.2.1'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/webcenter/fmw_12.2.1.0.0_wcportal_generic.jar'
  elsif node['fmw']['version'] == '12.2.1.1'
    fmw_installer_file = node['fmw']['tmp_dir'] + '/webcenter/fmw_12.2.1.1.0_wcportal.jar'
  end

elsif ['10.3.6'].include?(node['fmw']['version'])
  fmw_template = 'fmw_11g.rsp'
  fmw_oracle_home = node['fmw']['middleware_home_dir'] + '/Oracle_WC1'
  install_type = ''
  option_array = ['APPSERVER_TYPE=WLS',
                  "APPSERVER_LOCATION=#{node['fmw']['middleware_home_dir']}"]

  if node['os'].include?('windows')
    fmw_installer_file = node['fmw']['tmp_dir'] + '/webcenter/Disk1/setup.exe'
  else
    fmw_installer_file = node['fmw']['tmp_dir'] + '/webcenter/Disk1/runInstaller'
  end
end

if node['os'].include?('windows')
  unix = false
else
  unix = true
end

template node['fmw']['tmp_dir'] + '/wc_' + fmw_template do
  source fmw_template
  mode 0755                                                           if unix
  owner node['fmw']['os_user']                                        if unix
  group node['fmw']['os_group']                                       if unix
  variables(middleware_home_dir: node['fmw']['middleware_home_dir'],
            oracle_home: fmw_oracle_home,
            install_type: install_type,
            option_array: option_array)
end

# chef version 11
if VERSION.start_with? '11.'
  ruby_block "loading for chef 11 install webcenter extract" do
    block do
      if node['os'].include?('windows')
        res = Chef::Resource::Chef::Resource::FmwInstFmwExtractWindows.new('webcenter', run_context )
      else
        res = Chef::Resource::Chef::Resource::FmwInstFmwExtract.new('webcenter', run_context )
      end
      res.source_file         node['fmw_inst']['webcenter_source_file']
      res.source_2_file       node['fmw_inst']['webcenter_source_2_file'] if node['fmw_inst'].attribute?('webcenter_source_2_file')
      res.os_user             node['fmw']['os_user']                      if unix
      res.os_group            node['fmw']['os_group']                     if unix
      res.tmp_dir             node['fmw']['tmp_dir']
      res.version             node['fmw']['version']                      unless unix
      res.middleware_home_dir node['fmw']['middleware_home_dir']          unless unix
      res.run_action          :extract
    end
  end
else
  fmw_inst_fmw_extract 'webcenter' do
    action              :extract
    source_file         node['fmw_inst']['webcenter_source_file']
    source_2_file       node['fmw_inst']['webcenter_source_2_file']   if node['fmw_inst'].attribute?('webcenter_source_2_file')
    os_user             node['fmw']['os_user']                        if unix
    os_group            node['fmw']['os_group']                       if unix
    tmp_dir             node['fmw']['tmp_dir']
    version             node['fmw']['version']                        unless unix
    middleware_home_dir node['fmw']['middleware_home_dir']            unless unix
  end
end

if platform_family?('rhel')
  first_run_file = "#{node['fmw']['tmp_dir']}/yumgetrun"
  if ( !::File.exist?(first_run_file) )
    e = bash 'yum-update' do
      code <<-EOH
  yum update
  touch #{first_run_file}
      EOH
      ignore_failure true
      action :nothing
    end
    e.run_action(:run)
  end
end

if platform?('linux')
  package ["libaio-devel", "ksh", "compat-libcap1", "compat-libstdc++-33"] do
    ignore_failure true
    action :install
  end
end

if platform_family?('rhel')
  yum_package ["libaio-devel", "ksh", "compat-libcap1", "glibstdc++", "glibc", "libgcc", "compat-libstdc++-33"] do
    arch 'x86_64'
    ignore_failure true
    action :install
  end
  if node['platform_version'].to_f < 7.0
    yum_package ["libstdc++","glibc", "libgcc", "compat-libstdc++-33"] do
      arch 'i686'
      ignore_failure true
      action :install
    end
  end
end

# chef version 11
if VERSION.start_with? '11.'
  ruby_block "loading for chef 11 install webcenter" do
    block do
      if node['os'].include?('windows')
        res2 = Chef::Resource::Chef::Resource::FmwInstFmwInstallWindows.new('webcenter', run_context )
      elsif node['os'].include?('solaris2')
        res2 = Chef::Resource::Chef::Resource::FmwInstFmwInstallSolaris.new('webcenter', run_context )
      else
        res2 = Chef::Resource::Chef::Resource::FmwInstFmwInstallLinux.new('webcenter', run_context )
      end
      res2.java_home_dir       node['fmw']['java_home_dir']
      res2.installer_file      fmw_installer_file
      res2.rsp_file            node['fmw']['tmp_dir'] + '/wc_' + fmw_template
      res2.version             node['fmw']['version']
      res2.oracle_home_dir     fmw_oracle_home
      res2.orainst_dir         node['fmw']['orainst_dir']                      if unix
      res2.os_user             node['fmw']['os_user']                          if unix
      res2.os_group            node['fmw']['os_group']                         if unix
      res2.tmp_dir             node['fmw']['tmp_dir']
      res2.run_action          :install
    end
  end
else
  fmw_inst_fmw_install 'webcenter' do
    action              :install
    java_home_dir       node['fmw']['java_home_dir']
    installer_file      fmw_installer_file
    rsp_file            node['fmw']['tmp_dir'] + '/wc_' + fmw_template
    version             node['fmw']['version']
    oracle_home_dir     fmw_oracle_home
    orainst_dir         node['fmw']['orainst_dir']                     if unix
    os_user             node['fmw']['os_user']                         if unix
    os_group            node['fmw']['os_group']                        if unix
    tmp_dir             node['fmw']['tmp_dir']
  end
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
