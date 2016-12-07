
default['fmw']['version']                 = '12.1.3' # 10.3.6|12.1.1|12.1.2|12.1.3|12.2.1|12.2.1.1|12.2.1.2
default['fmw_wls']['install_type']        = 'wls' # infra or wls

if platform_family?('windows')
  default['fmw']['middleware_home_dir']   = 'C:/oracle/middleware'
  default['fmw']['ora_inventory_dir']     = 'C:\\Program Files\\Oracle\\Inventory'
  default['fmw']['tmp_dir']               = 'C:/temp'
else
  default['fmw']['middleware_home_dir']   = '/opt/oracle/middleware'
  default['fmw']['os_user']               = 'oracle'
  default['fmw']['os_group']              = 'oinstall'
  default['fmw']['os_shell']              = '/bin/bash'
end

if platform_family?('debian') or platform_family?('rhel')
  default['fmw']['orainst_dir']       = '/etc'
  default['fmw']['user_home_dir']     = '/home'
  default['fmw']['ora_inventory_dir'] = '/home/oracle/oraInventory'
  default['fmw']['tmp_dir']           = '/tmp'
elsif platform_family?('solaris2')
  default['fmw']['orainst_dir']       = '/var/opt/oracle'
  default['fmw']['user_home_dir']     = '/export/home'
  default['fmw']['ora_inventory_dir'] = '/export/home/oracle/oraInventory'
  default['fmw']['tmp_dir']           = '/var/tmp'
end
