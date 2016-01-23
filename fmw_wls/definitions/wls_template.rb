#
# Cookbook Name:: fmw_wls
# Definition:: wls_template
#
# Copyright 2015 Oracle. All Rights Reserved
#
define :wls_template, :unix => true, :middleware_home_dir => nil, :tmp_dir => nil, :template => nil, :install_type => nil, :os_group => nil, :os_user => nil do

  if params[:install_type] == 'wls'
    install_type = 'WebLogic Server'
  elsif params[:install_type] == 'infra'
    install_type = 'Fusion Middleware Infrastructure'
  else
    install_type = 'WebLogic Server'
  end

  # add the webLogic silent response
  template "#{params[:tmp_dir]}/#{params[:template]}" do
    source params[:template]
    mode   0755              if params[:unix]
    owner  params[:os_user]  if params[:unix]
    group  params[:os_group] if params[:unix]
    variables(middleware_home_dir: params[:middleware_home_dir],
              install_type:        install_type)
  end

end