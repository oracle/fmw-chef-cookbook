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

OSB_SERVER_STARTUP_ARGUMENTS = '<%= @osb_server_startup_arguments %>'
OSB_SERVER_LISTEN_PORT       = 8011
ESS_CLUSTER                  = '<%= @ess_cluster %>'
SOA_CLUSTER                  = '<%= @soa_cluster %>'
OSB_CLUSTER                  = '<%= @osb_cluster %>'
BAM_CLUSTER                  = '<%= @bam_cluster %>'

# templates
WLS_EM_TEMPLATE   = '<%= @wls_em_template %>'
WLS_SB_TEMPLATE   = '<%= @wls_sb_template %>'
WLS_WS_TEMPLATE   = '<%= @wls_ws_template %>'

# repository
REPOS_DBURL         = '<%= @repository_database_url %>'
REPOS_DBUSER_PREFIX = '<%= @repository_prefix %>'
REPOS_DBPASSWORD    = sys.argv[2]

BPM_ENABLED=<%= @bpm_enabled %>

readDomain(DOMAIN_PATH)

cd('/')
setOption( "AppDir", APP_PATH )

print 'Adding EM Template'
try:
  addTemplate(WLS_EM_TEMPLATE)
except:
  print "Probably already added error:", sys.exc_info()[0]

dumpStack()

print 'Adding Service Bus Template'
try:
  addTemplate(WLS_WS_TEMPLATE)
except:
  print "Probably already added error:", sys.exc_info()[0]

addTemplate(WLS_SB_TEMPLATE)
dumpStack()

if OSB_CLUSTER:
  pass
else:
  print 'change osb_server1'
  cd('/')
  changeManagedServer('osb_server1', MACHINE_NAME, ADMIN_SERVER_LISTEN_ADDRESS, OSB_SERVER_LISTEN_PORT, OSB_SERVER_STARTUP_ARGUMENTS, JAVA_HOME)

if WEBLOGIC_VERSION == '10.3.6':

  print 'Change datasource wlsbjmsrpDataSource'
  changeDatasourceDriver('wlsbjmsrpDataSource', REPOS_DBUSER_PREFIX+'_SOAINFRA', REPOS_DBPASSWORD, REPOS_DBURL,'oracle.jdbc.OracleDriver')

  if OSB_CLUSTER:
    osbServers = getClusterServers(OSB_CLUSTER, ADMIN_SERVER_NAME)
    if 'osb_server1' in osbServers:
      pass
    else:
      print "delete osb_server1"
      cd('/')
      delete('osb_server1', 'Server')

    change11gFMWTargets(ADMIN_SERVER_NAME, SOA_CLUSTER, OSB_CLUSTER, BAM_CLUSTER, BPM_ENABLED)

    updateDomain()
    dumpStack()

    closeDomain()
    readDomain(DOMAIN_PATH)

    cleanJMS('configwiz-jms', None, None)
    cleanJMS('jmsResources', 'wlsbJMSServer', None)
    cleanJMS('WseeJmsModule', 'WseeJmsServer_auto', 'WseeFileStore_auto')
    cleanJMS(None, None, 'FileStore_auto')

    sb11g(OSB_CLUSTER)

if WEBLOGIC_VERSION != '10.3.6':
    print 'Change datasource LocalScvTblDataSource for service table'
    changeDatasource('LocalSvcTblDataSource', REPOS_DBUSER_PREFIX+'_STB', REPOS_DBPASSWORD, REPOS_DBURL)
    print 'Call getDatabaseDefaults which reads the service table'
    getDatabaseDefaults()

    changeDatasourceToXA('wlsbjmsrpDataSource')
    changeDatasourceToXA('SOADataSource')

    print 'end datasources'

    print 'Add server groups WSM-CACHE-SVR WSMPM-MAN-SVR JRF-MAN-SVR to AdminServer'
    serverGroup = ["WSM-CACHE-SVR" , "WSMPM-MAN-SVR" , "JRF-MAN-SVR"]
    setServerGroups(ADMIN_SERVER_NAME, serverGroup)

    serverGroup = ["OSB-MGD-SVRS-COMBINED"]
    if OSB_CLUSTER:
      if WEBLOGIC_VERSION in ['12.2.1', '12.2.1.1']:
        cleanJMS('UMSJMSSystemResource', 'UMSJMSServer_auto', 'UMSJMSFileStore_auto')

      print 'Add server group OSB-MGD-SVRS-COMBINED to cluster'
      cd('/')
      setServerGroups('osb_server1', [])

      osbServers = getClusterServers(OSB_CLUSTER, ADMIN_SERVER_NAME)
      cd('/')
      for i in range(len(osbServers)):
        print "Add server group OSB-MGD-SVRS-COMBINED to " + osbServers[i]
        setServerGroups(osbServers[i] , serverGroup)

      print 'Assign cluster to defaultCoherenceCluster'
      cd('/')
      assign('Cluster',OSB_CLUSTER,'CoherenceClusterSystemResource','defaultCoherenceCluster')
      cd('/')
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

      if 'osb_server1' in osbServers:
        pass
      else:
        print "delete osb_server1"
        cd('/')
        delete('osb_server1', 'Server')

      if WEBLOGIC_VERSION in ['12.2.1', '12.2.1.1']:
        updateDomain()
        dumpStack()

        closeDomain()
        readDomain(DOMAIN_PATH)

        cleanJMS('WseeJmsModule', 'WseeJmsServer_auto', 'WseeFileStore_auto')
        sb12c(OSB_CLUSTER)

        cleanJMS('UMSJMSSystemResource', 'UMSJMSServer_auto', 'UMSJMSFileStore_auto')
        recreateUMSJms12c(ADMIN_SERVER_NAME, SOA_CLUSTER, OSB_CLUSTER, BAM_CLUSTER, ESS_CLUSTER, All)

    else:
      print 'Add server group OSB-MGD-SVRS-COMBINED to osb_server1'
      setServerGroups('osb_server1', serverGroup)

    print 'end server groups'

updateDomain()
dumpStack()

closeDomain()

print('Exiting...')
exit()
