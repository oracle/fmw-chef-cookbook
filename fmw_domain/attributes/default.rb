include_attribute 'fmw_wls'

default['fmw_domain']['nodemanager_port']               = 5556
default['fmw_domain']['nodemanager_service_description'] = nil

if platform_family?('windows')
  default['fmw_domain']['domains_dir']    = 'C:/oracle/middleware/user_projects/domains'
  default['fmw_domain']['apps_dir']       = 'C:/oracle/middleware/user_projects/applications'

  default['fmw_domain']['adminserver_startup_arguments']  = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
  default['fmw_domain']['osb_server_startup_arguments']   = '-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
  default['fmw_domain']['soa_server_startup_arguments']   = '-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
  default['fmw_domain']['bam_server_startup_arguments']   = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
  default['fmw_domain']['ess_server_startup_arguments']   = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
else
  default['fmw_domain']['domains_dir']    = '/opt/oracle/middleware/user_projects/domains'
  default['fmw_domain']['apps_dir']       = '/opt/oracle/middleware/user_projects/applications'
end

case platform_family
when 'debian', 'rhel'
  default['fmw']['orainst_dir']       = '/etc'
  default['fmw']['user_home_dir']     = '/home'
  default['fmw']['ora_inventory_dir'] = '/home/oracle/oraInventory'
  default['fmw']['tmp_dir']           = '/tmp'

  default['fmw_domain']['adminserver_startup_arguments']  = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Djava.security.egd=file:/dev/./urandom'
  default['fmw_domain']['osb_server_startup_arguments']   = '-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Djava.security.egd=file:/dev/./urandom'
  default['fmw_domain']['soa_server_startup_arguments']   = '-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Djava.security.egd=file:/dev/./urandom'
  default['fmw_domain']['bam_server_startup_arguments']   = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Djava.security.egd=file:/dev/./urandom'
  default['fmw_domain']['ess_server_startup_arguments']   = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m -Djava.security.egd=file:/dev/./urandom'

when 'solaris2'
  default['fmw']['orainst_dir']       = '/var/opt/oracle'
  default['fmw']['user_home_dir']     = '/export/home'
  default['fmw']['ora_inventory_dir'] = '/export/home/oracle/oraInventory'
  default['fmw']['tmp_dir']           = '/var/tmp'

  default['fmw_domain']['adminserver_startup_arguments']  = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
  default['fmw_domain']['osb_server_startup_arguments']   = '-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
  default['fmw_domain']['soa_server_startup_arguments']   = '-XX:PermSize=512m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
  default['fmw_domain']['bam_server_startup_arguments']   = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'
  default['fmw_domain']['ess_server_startup_arguments']   = '-XX:PermSize=256m -XX:MaxPermSize=512m -Xms1024m -Xmx1024m'

end
