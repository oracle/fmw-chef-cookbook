#
# Cookbook Name:: fmw_wls
# Definition:: wls_install
#
# Copyright 2015 Oracle. All Rights Reserved
#
define :wls_install, :unix => true, :middleware_home_dir => nil, :java_home_dir => nil, :tmp_dir => nil, :version => nil, :os_group => nil, :os_user => nil, :source2_file => nil, :template => nil, :orainst_dir => nil do

  if params[:unix]
    if ['solaris2'].include?(node['os'])
      java_params = '-d64'
    else
      java_params = ''
    end

    if ['10.3.6', '12.1.1'].include?(params[:version])
      execute 'Install WLS' do
        command "#{params[:java_home_dir]}/bin/java #{java_params} -Xmx1024m -Djava.io.tmpdir=#{params[:tmp_dir]} -Duser.country=US -Duser.language=en -jar #{params[:source2_file]} -mode=silent -silent_xml=#{params[:tmp_dir]}/#{params[:template]} -log=#{params[:tmp_dir]}/wls.log -log_priority=info"
        environment('JAVA_VENDOR' => 'Sun',
                    'JAVA_HOME'   => params[:java_home_dir])
        user  params[:os_user]
        group params[:os_group]
        cwd   params[:tmp_dir]
      end
    elsif ['12.2.1', '12.2.1.1', '12.2.1.2', '12.2.1.3', '12.1.3', '12.1.2'].include?(params[:version])
      execute 'Install WLS' do
        command "#{params[:java_home_dir]}/bin/java #{java_params} -Xmx1024m -Djava.io.tmpdir=#{params[:tmp_dir]} -jar #{params[:source2_file]} -silent -responseFile #{params[:tmp_dir]}/#{params[:template]} -invPtrLoc #{params[:orainst_dir]}/oraInst.loc"
        user  params[:os_user]
        group params[:os_group]
        cwd   params[:tmp_dir]
      end
    end
  else
    if ['10.3.6', '12.1.1'].include?(params[:version])
      execute 'Install WLS' do
        command "#{params[:java_home_dir]}\\bin\\java.exe -Xmx1024m -Djava.io.tmpdir=#{params[:tmp_dir]} -Duser.country=US -Duser.language=en -jar #{params[:source2_file]} -mode=silent -silent_xml=#{params[:tmp_dir]}/#{params[:template]} -log=#{params[:tmp_dir]}/wls.log -log_priority=info"
        environment('JAVA_VENDOR' => 'Sun',
                    'JAVA_HOME'   => params[:java_home_dir])
      end
    elsif ['12.2.1', '12.2.1.1', '12.2.1.2', '12.2.1.3', '12.1.3', '12.1.2'].include?(params[:version])
      execute 'Install WLS' do
        command "#{params[:java_home_dir]}\\bin\\java.exe -Xmx1024m -Djava.io.tmpdir=#{params[:tmp_dir]} -jar #{params[:source2_file]} -silent -responseFile #{params[:tmp_dir]}/#{params[:template]} -logLevel fine"
      end
    end
  end
end
