#
# Cookbook Name:: fmw_wls
# Definition:: ora_inst
#
# Copyright 2015 Oracle. All Rights Reserved
#
define :ora_inst, :orainst_dir => nil, :ora_inventory_dir => nil, :os_group => nil, :os_user => nil do

  # add oraInst.loc to /etc for the oracle inventory location
  template "#{params[:orainst_dir]}/oraInst.loc" do
    cookbook 'fmw_wls'
    source 'oraInst.loc'
    mode 0755
    variables(ora_inventory_dir: params[:ora_inventory_dir],
              os_group:          params[:os_group])
    action :create
  end

  # create the oracle inventory location under the WebLogic OS user
  directory params[:ora_inventory_dir] do
    owner params[:os_user]
    group params[:os_group]
    mode 0775
    action :create
  end

end