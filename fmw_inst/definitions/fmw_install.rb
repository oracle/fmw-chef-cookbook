#
# Cookbook Name:: fmw_inst
# Definition:: fmw_install
#
# Copyright 2015 Oracle. All Rights Reserved
#
define :fmw_install, :unix => true, :installer_file => nil, :rsp_file => nil, :java_home_dir => nil, :tmp_dir => nil, :version => nil, :os_group => nil, :os_user => nil, :orainst_dir => nil do

  if params[:unix]
    if ['solaris2'].include?(node['os'])
      java_params = '-d64'
    else
      java_params = ''
    end

    if ['10.3.6', '12.1.1'].include?(params[:version])
      execute "Install #{params[:name]}" do
        command "#{params[:installer_file]} -silent -response #{params[:rsp_file]} -waitforcompletion -invPtrLoc #{params[:orainst_dir]}/oraInst.loc -ignoreSysPrereqs -jreLoc #{params[:java_home_dir]} -Djava.io.tmpdir=#{params[:tmp_dir]}"
        user  params[:os_user]
        group params[:os_group]
        cwd   params[:tmp_dir]
      end
    elsif ['12.2.1', '12.2.1.1', '12.1.3', '12.1.2'].include?(params[:version])
      execute "Install #{params[:name]}" do
        command "#{params[:java_home_dir]}/bin/java #{java_params} -Xmx1024m -Djava.io.tmpdir=#{params[:tmp_dir]} -jar #{params[:installer_file]} -waitforcompletion -silent -responseFile #{params[:rsp_file]} -invPtrLoc #{params[:orainst_dir]}/oraInst.loc -jreLoc #{params[:java_home_dir]}"
        user  params[:os_user]
        group params[:os_group]
        cwd   params[:tmp_dir]
      end
    end
  else
    if ['10.3.6', '12.1.1'].include?(params[:version])
      execute "Install #{params[:name]}" do
        command "#{params[:installer_file]} -silent -response #{params[:rsp_file]} -waitforcompletion -jreLoc #{params[:java_home_dir]} -ignoreSysPrereqs -Djava.io.tmpdir=#{params[:tmp_dir]}"
        cwd     params[:tmp_dir]
      end
    elsif ['12.2.1', '12.2.1.1', '12.1.3', '12.1.2'].include?(params[:version])
      execute "Install #{params[:name]}" do
        command "#{params[:java_home_dir]}\\bin\\java.exe -Xmx1024m -Djava.io.tmpdir=#{params[:tmp_dir]} -jar #{params[:installer_file]} -waitforcompletion -silent -responseFile #{params[:rsp_file]} -jreLoc #{params[:java_home_dir]}"
        cwd     params[:tmp_dir]
      end
    end
  end
end
