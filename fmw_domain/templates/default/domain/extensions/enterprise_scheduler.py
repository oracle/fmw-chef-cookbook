execfile('<%= @tmp_dir %>/common.py')

# weblogic node params
WLHOME           = '<%= @weblogic_home_dir %>'
JAVA_HOME        = '<%= @java_home_dir %>'
WEBLOGIC_VERSION = '<%= @version %>'

# domain params
DOMAIN_PATH       = '<%= @domain_dir %>'
DOMAIN            = '<%= @domain_name %>'
APP_PATH          = '<%= @app_dir %>'

# adminserver params
ADMIN_SERVER_NAME           = '<%= @adminserver_name %>'
ADMIN_SERVER_LISTEN_ADDRESS = '<%= @adminserver_listen_address %>'
MACHINE_NAME                = 'LocalMachine'

ESS_SERVER_STARTUP_ARGUMENTS = '<%= @ess_server_startup_arguments %>'
ESS_SERVER_LISTEN_PORT       = 8201
ESS_CLUSTER                  = '<%= @ess_cluster %>'
SOA_CLUSTER                  = '<%= @soa_cluster %>'
OSB_CLUSTER                  = '<%= @osb_cluster %>'
BAM_CLUSTER                  = '<%= @bam_cluster %>'

# templates
WLS_EM_TEMPLATE     = '<%= @wls_em_template %>'
WLS_ESS_EM_TEMPLATE = '<%= @wls_ess_em_template %>'
WLS_ESS_TEMPLATE    = '<%= @wls_ess_template %>'

# repository
REPOS_DBURL         = '<%= @repository_database_url %>'
REPOS_DBUSER_PREFIX = '<%= @repository_prefix %>'
REPOS_DBPASSWORD    = sys.argv[2]

readDomain(DOMAIN_PATH)

cd('/')
setOption( "AppDir", APP_PATH )

print 'Adding EM Template'
try:
  addTemplate(WLS_EM_TEMPLATE)
except:
  print "Probably already added error:", sys.exc_info()[0]

print 'Adding ESS Template'
addTemplate(WLS_ESS_TEMPLATE)
addTemplate(WLS_ESS_EM_TEMPLATE)

if ESS_CLUSTER:
  pass
else:
  print 'change ess_server1'
  cd('/')
  changeManagedServer('ess_server1', MACHINE_NAME, ADMIN_SERVER_LISTEN_ADDRESS, ESS_SERVER_LISTEN_PORT, ESS_SERVER_STARTUP_ARGUMENTS, JAVA_HOME)

print 'Change datasources'

print 'Change datasource LocalScvTblDataSource'
changeDatasource('LocalSvcTblDataSource', REPOS_DBUSER_PREFIX+'_STB', REPOS_DBPASSWORD, REPOS_DBURL)

print 'Call getDatabaseDefaults which reads the service table'
getDatabaseDefaults()

# changeDatasourceToXA('EssDS')

print 'end datasources'

print 'Add server groups WSM-CACHE-SVR WSMPM-MAN-SVR JRF-MAN-SVR to AdminServer'
serverGroup = ["WSM-CACHE-SVR" , "WSMPM-MAN-SVR" , "JRF-MAN-SVR"]
setServerGroups(ADMIN_SERVER_NAME, serverGroup)

serverGroup = ["ESS-MGD-SVRS"]
if ESS_CLUSTER:
  print 'Add server group ESS-MGD-SVRS to cluster'
  cd('/')
  setServerGroups('ess_server1', [])

  essServers = getClusterServers(ESS_CLUSTER, ADMIN_SERVER_NAME)
  cd('/')
  for i in range(len(essServers)):
    print "Add server group ESS-MGD-SVRS to " + essServers[i]
    setServerGroups(essServers[i] , serverGroup)

  print 'Assign cluster to defaultCoherenceCluster'
  cd('/')
  assign('Cluster',ESS_CLUSTER,'CoherenceClusterSystemResource','defaultCoherenceCluster')
  cd('/CoherenceClusterSystemResource/defaultCoherenceCluster')

  AllArray = []
  if SOA_CLUSTER:
    AllArray.append(SOA_CLUSTER)
  if BAM_CLUSTER:
    AllArray.append(BAM_CLUSTER)
  if OSB_CLUSTER:
    AllArray.append(OSB_CLUSTER)
  if ESS_CLUSTER:
    AllArray.append(ESS_CLUSTER)

  All = ','.join(AllArray)
  set('Target', All)

  if 'ess_server1' in essServers:
    pass
  else:
    print "delete ess_server1"
    cd('/')
    delete('ess_server1', 'Server')

  if WEBLOGIC_VERSION in ['12.2.1', '12.2.1.1']:
    updateDomain()
    dumpStack()

    closeDomain()
    readDomain(DOMAIN_PATH)

    cleanJMS('UMSJMSSystemResource', 'UMSJMSServer_auto', 'UMSJMSFileStore_auto')
    recreateUMSJms12c(ADMIN_SERVER_NAME, SOA_CLUSTER, OSB_CLUSTER, BAM_CLUSTER, ESS_CLUSTER, All)

else:
  print 'Add server group ESS-MGD-SVRS to ess_server1'
  setServerGroups('ess_server1', serverGroup)

print 'end server groups'


updateDomain()
dumpStack()

closeDomain()

print('Exiting...')
exit()
