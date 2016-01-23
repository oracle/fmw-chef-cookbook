# load common defs
execfile('<%= @tmp_dir %>/common.py')

# weblogic node params
WLHOME         = '<%= @weblogic_home_dir %>'
JAVA_HOME      = '<%= @java_home_dir %>'
BASE_TEMPLATE  = '<%= @wls_base_template %>'

# domain params
DOMAIN_PATH       = '<%= @domain_dir %>'
DOMAIN            = '<%= @domain_name %>'
WEBLOGIC_USER     = '<%= @weblogic_user %>'
WEBLOGIC_PASSWORD = sys.argv[1]

# adminserver params
ADMIN_SERVER_NAME              = '<%= @adminserver_name %>'
ADMIN_SERVER_STARTUP_ARGUMENTS = '<%= @adminserver_startup_arguments %>'
ADMIN_SERVER_LISTEN_ADDRESS    = '<%= @adminserver_listen_address %>'
ADMIN_SERVER_LISTEN_PORT       = <%= @adminserver_listen_port %>
MACHINE_NAME                   = 'LocalMachine'
NODEMANAGER_LISTEN_PORT        = <%= @nodemanager_port %>

# domain configuration
NODEMANAGERS = [<% @nodemanagers.each do |nodemanager| %>'<%= nodemanager['id'] %>',<% end %>]
<% @nodemanagers.each do |nodemanager| %>
nodemanagers_<%= nodemanager['id'] %>_listen_address='<%= nodemanager['listen_address'] %>'
<% end %>

SERVERS = [<% @servers.each do |server| %>'<%= server['id'] %>',<% end %>]
<% @servers.each do |server| %>
servers_<%= server['id'] %>_nodemanager='<%= server['nodemanager'] %>'
servers_<%= server['id'] %>_listen_address='<%= server['listen_address'] %>'
servers_<%= server['id'] %>_listen_port=<%= server['listen_port'] %>
servers_<%= server['id'] %>_arguments='<%= server['arguments'] %>'
<% end %>

CLUSTERS = [<% @clusters.each do |cluster| %>'<%= cluster['id'] %>',<% end %>]
<% @clusters.each do |cluster| %>
clusters_<%= cluster['id'] %>_members=<%= cluster['members'] %>
<% end %>

print('Start normal domain... with template ' + BASE_TEMPLATE)
readTemplate(BASE_TEMPLATE)

print('Create machine LocalMachine with type UnixMachine')
createMachine('UnixMachine', MACHINE_NAME, ADMIN_SERVER_LISTEN_ADDRESS, NODEMANAGER_LISTEN_PORT)

print('Change the AdminServer')
changeAdminServer(ADMIN_SERVER_NAME, MACHINE_NAME, ADMIN_SERVER_LISTEN_ADDRESS,ADMIN_SERVER_LISTEN_PORT, ADMIN_SERVER_STARTUP_ARGUMENTS, JAVA_HOME)

print('Set password...')
setWebLogicPassword(WEBLOGIC_USER, WEBLOGIC_PASSWORD)

setOption('JavaHome', JAVA_HOME)

for NODEMANAGER in NODEMANAGERS:
  NODEMANAGERS_LISTEN_ADDRESS = globals()['nodemanagers_'+NODEMANAGER+'_listen_address']
  print "nodemgr " + NODEMANAGER + " address " + NODEMANAGERS_LISTEN_ADDRESS
  createMachine('UnixMachine', NODEMANAGER, NODEMANAGERS_LISTEN_ADDRESS, NODEMANAGER_LISTEN_PORT)

for SERVER in SERVERS:
  SERVER_NODEMANAGER = globals()['servers_'+SERVER+'_nodemanager']
  SERVER_LISTEN_ADDRESS = globals()['servers_'+SERVER+'_listen_address']
  SERVER_LISTEN_PORT = globals()['servers_'+SERVER+'_listen_port']
  SERVER_ARGUMENTS = globals()['servers_'+SERVER+'_arguments']
  cd('/')
  create(SERVER, 'Server')
  changeManagedServer(SERVER, SERVER_NODEMANAGER, SERVER_LISTEN_ADDRESS, SERVER_LISTEN_PORT, SERVER_ARGUMENTS, JAVA_HOME)
  print "server " + SERVER + " nodemanager " + SERVER_NODEMANAGER + " address " + SERVER_LISTEN_ADDRESS + " port " + str(SERVER_LISTEN_PORT) + " arguments " + str(SERVER_ARGUMENTS)

for CLUSTER in CLUSTERS:
  CLUSTER_MEMBERS = globals()['clusters_'+CLUSTER+'_members']
  print "cluster " + CLUSTER
  cd('/')
  create(CLUSTER, 'Cluster')

  for CLUSTE_MEMBER in CLUSTER_MEMBERS:
    print "cluster " + CLUSTER + " member " + CLUSTE_MEMBER
    cd('/')
    assign('Server',CLUSTE_MEMBER,'Cluster',CLUSTER)

print('write domain...')
# write path + domain name
writeDomain(DOMAIN_PATH)
closeTemplate()

# create startup and boot.properties for the adminserver
createAdminStartupPropertiesFile(DOMAIN_PATH+'/servers/' + ADMIN_SERVER_NAME + '/data/nodemanager', ADMIN_SERVER_STARTUP_ARGUMENTS)
createBootPropertiesFile(DOMAIN_PATH + '/servers/' + ADMIN_SERVER_NAME + '/security', 'boot.properties', WEBLOGIC_USER, WEBLOGIC_PASSWORD)

print('Exiting...')
exit()
