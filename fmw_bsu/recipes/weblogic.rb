#
# Cookbook Name:: fmw_bsu
# Recipe:: weblogic
#
# Copyright 2015 Oracle. All Rights Reserved
# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Starting compile phase"

return unless ['10.3.6', '12.1.1'].include?(node['fmw']['version'])

include_recipe 'fmw_wls::install'

fail 'fmw_bsu attributes cannot be empty' unless node.attribute?('fmw_bsu')
fail 'source_file parameter cannot be empty' unless node['fmw_bsu'].attribute?('source_file')
fail 'patch_id parameter cannot be empty' unless node['fmw_bsu'].attribute?('patch_id')

if ['solaris2', 'linux'].include?(node['os'])

  directory node['fmw']['middleware_home_dir'] + '/utils/bsu/cache_dir' do
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
    mode '0755'
    recursive true
    action :create
  end

  execute "extract #{node['fmw_bsu']['patch_id']}" do
    command "unzip -o #{node['fmw_bsu']['source_file']} -d #{node['fmw']['middleware_home_dir']}/utils/bsu/cache_dir"
    creates "#{node['fmw']['middleware_home_dir']}/utils/bsu/cache_dir/#{node['fmw_bsu']['patch_id']}.jar"
    cwd node['fmw']['tmp_dir']
    user node['fmw']['os_user']
    group node['fmw']['os_group']
  end

  bsu_utility = "#{node['fmw']['middleware_home_dir']}/utils/bsu/bsu.sh"
  # have to do like this because of sed on solaris
  execute "patch bsu.sh" do
    command "sed -e's/MEM_ARGS=\"-Xms256m -Xmx512m\"/MEM_ARGS=\"-Xms512m -Xmx752m -XX:-UseGCOverheadLimit\"/g' #{bsu_utility} > #{bsu_utility}.tmp && mv #{bsu_utility}.tmp #{bsu_utility}"
    not_if "grep 'MEM_ARGS=\"-Xms512m -Xmx752m -XX:-UseGCOverheadLimit\"' #{bsu_utility}"
    user node['fmw']['os_user']
    group node['fmw']['os_group']
  end

  file bsu_utility do
    owner node['fmw']['os_user']
    group node['fmw']['os_group']
    mode '0755'
    action :create
  end

elsif node['os'].include?('windows')

  directory node['fmw']['middleware_home_dir'] + '\\utils\\bsu\\cache_dir' do
    recursive true
    action :create
  end

  path = "#{node['fmw']['middleware_home_dir']}\\wlserver_10.3\\server\\adr"

  execute "extract #{node['fmw_bsu']['patch_id']}" do
    command "#{path}\\unzip.exe -o #{node['fmw_bsu']['source_file']} -d #{node['fmw']['middleware_home_dir']}/utils/bsu/cache_dir"
    creates "#{node['fmw']['middleware_home_dir']}/utils/bsu/cache_dir/#{node['fmw_bsu']['patch_id']}.jar"
  end

end

if VERSION.start_with? '11.'
  ruby_block "loading for chef 11 bsu install" do
    block do
      if node['os'].include?('windows')
        res = Chef::Resource::Chef::Resource::FmwBsuBsuWindows.new( node['fmw_bsu']['patch_id'], run_context )
      else
        res = Chef::Resource::Chef::Resource::FmwBsuBsu.new( node['fmw_bsu']['patch_id'], run_context )
      end
      res.patch_id            node['fmw_bsu']['patch_id']
      res.middleware_home_dir node['fmw']['middleware_home_dir']
      res.os_user             node['fmw']['os_user'] if ['solaris2', 'linux'].include?(node['os'])
      res.run_action          :install
    end
  end
else
  fmw_bsu_bsu node['fmw_bsu']['patch_id'] do
    action :install
    patch_id node['fmw_bsu']['patch_id']
    middleware_home_dir node['fmw']['middleware_home_dir']
    os_user node['fmw']['os_user'] if ['solaris2', 'linux'].include?(node['os'])
  end
end

# log  "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished execution phase"
puts "####{cookbook_name}::#{recipe_name} #{Time.now.inspect}: Finished compile phase"
