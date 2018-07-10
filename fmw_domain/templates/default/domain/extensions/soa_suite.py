import sys

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
NODEMANAGER_LISTEN_PORT     = <%= @nodemanager_port %>

SOA_SERVER_STARTUP_ARGUMENTS = '<%= @soa_server_startup_arguments %>'
SOA_SERVER_LISTEN_PORT       = 8001
ESS_CLUSTER                  = '<%= @ess_cluster %>'
SOA_CLUSTER                  = '<%= @soa_cluster %>'
OSB_CLUSTER                  = '<%= @osb_cluster %>'
BAM_CLUSTER                  = '<%= @bam_cluster %>'

# templates
WLS_EM_TEMPLATE        = '<%= @wls_em_template %>'
WLS_JRF_TEMPLATE       = '<%= @wls_jrf_template %>'
WLS_APPL_CORE_TEMPLATE = '<%= @wls_appl_core_template %>'
WLS_WSMPM_TEMPLATE     = '<%= @wls_wsmpm_template %>'
WLS_SOA_TEMPLATE       = '<%= @wls_soa_template %>'
WLS_BPM_TEMPLATE       = '<%= @wls_bpm_template %>'
WLS_B2B_TEMPLATE       = '<%= @wls_b2b_template %>'

# repository
REPOS_DBURL         = '<%= @repository_database_url %>'
REPOS_DBUSER_PREFIX = '<%= @repository_prefix %>'
REPOS_DBPASSWORD    = sys.argv[2]

BPM_ENABLED=<%= @bpm_enabled %>

readDomain(DOMAIN_PATH)

cd('/')
setOption( "AppDir", APP_PATH )

print 'Adding SOA Template'
addTemplate(WLS_APPL_CORE_TEMPLATE)

try:
  addTemplate(WLS_JRF_TEMPLATE)
except:
  print "Probably already added error:", sys.exc_info()[0]

try:
  addTemplate(WLS_WSMPM_TEMPLATE)
except:
  print "Probably already added error:", sys.exc_info()[0]

addTemplate(WLS_SOA_TEMPLATE)

if BPM_ENABLED == true:
  print 'Adding BPM Template'
  addTemplate(WLS_BPM_TEMPLATE)

if WEBLOGIC_VERSION != '10.3.6':
  print 'Adding B2B Template'
  addTemplate(WLS_B2B_TEMPLATE)

if WEBLOGIC_VERSION == '10.3.6':
  print 'Adding EM Template'
  try:
    addTemplate(WLS_JRF_TEMPLATE)
  except:
    print "Probably already added error:", sys.exc_info()[0]

  try:
    addTemplate(WLS_EM_TEMPLATE)
  except:
    print "Probably already added error:", sys.exc_info()[0]

  cd('/')
  # destroy the normal one
  delete('LocalMachine','Machine')
  print('change the default machine LocalMachine with type Machine')
  createMachine('UnixMachine', MACHINE_NAME, ADMIN_SERVER_LISTEN_ADDRESS, NODEMANAGER_LISTEN_PORT)

print 'Change AdminServer'
cd('/Servers/'+ADMIN_SERVER_NAME)
set('Machine','LocalMachine')

if SOA_CLUSTER:
  pass
else:
  print 'change soa_server1'
  cd('/')
  changeManagedServer('soa_server1', MACHINE_NAME, ADMIN_SERVER_LISTEN_ADDRESS, SOA_SERVER_LISTEN_PORT, SOA_SERVER_STARTUP_ARGUMENTS, JAVA_HOME)

if WEBLOGIC_VERSION == '10.3.6':

  print 'Change datasources'
  changeDatasource('EDNDataSource', REPOS_DBUSER_PREFIX+'_SOAINFRA', REPOS_DBPASSWORD, REPOS_DBURL)
  changeDatasource('EDNLocalTxDataSource', REPOS_DBUSER_PREFIX+'_SOAINFRA', REPOS_DBPASSWORD, REPOS_DBURL)
  changeDatasource('OraSDPMDataSource', REPOS_DBUSER_PREFIX+'_ORASDPM', REPOS_DBPASSWORD, REPOS_DBURL)
  changeDatasource('SOADataSource', REPOS_DBUSER_PREFIX+'_SOAINFRA', REPOS_DBPASSWORD, REPOS_DBURL)
  changeDatasource('SOALocalTxDataSource', REPOS_DBUSER_PREFIX+'_SOAINFRA', REPOS_DBPASSWORD, REPOS_DBURL)
  changeDatasource('mds-owsm', REPOS_DBUSER_PREFIX+'_MDS', REPOS_DBPASSWORD, REPOS_DBURL)
  changeDatasource('mds-soa', REPOS_DBUSER_PREFIX+'_MDS', REPOS_DBPASSWORD, REPOS_DBURL)

  if SOA_CLUSTER:
    soaServers = getClusterServers(SOA_CLUSTER, ADMIN_SERVER_NAME)
    if 'soa_server1' in soaServers:
      pass
    else:
      print "delete soa_server1"
      cd('/')
      delete('soa_server1', 'Server')

    change11gFMWTargets(ADMIN_SERVER_NAME, SOA_CLUSTER, OSB_CLUSTER, BAM_CLUSTER, BPM_ENABLED)

    updateDomain()
    dumpStack()

    closeDomain()
    readDomain(DOMAIN_PATH)

    cleanJMS('SOAJMSModule', 'SOAJMSServer_auto', 'SOAJMSFileStore_auto')
    cleanJMS('UMSJMSSystemResource', 'UMSJMSServer_auto', 'UMSJMSFileStore_auto')
    cleanJMS('PS6SOAJMSModule', 'PS6SOAJMSServer_auto', 'PS6SOAJMSFileStore_auto')
    cleanJMS('BPMJMSModule', 'BPMJMSServer_auto', 'BPMJMSFileStore_auto')

    soa11g_bpm(SOA_CLUSTER, BPM_ENABLED)
    soa11g_ps6(SOA_CLUSTER)

if WEBLOGIC_VERSION != '10.3.6':

    print 'Change datasources'

    print 'Change datasource LocalScvTblDataSource'
    changeDatasource('LocalSvcTblDataSource', REPOS_DBUSER_PREFIX+'_STB', REPOS_DBPASSWORD, REPOS_DBURL)

    print 'Call getDatabaseDefaults which reads the service table'
    getDatabaseDefaults()

    changeDatasourceToXA('EDNDataSource')
    changeDatasourceToXA('OraSDPMDataSource')
    changeDatasourceToXA('SOADataSource')

    print 'end datasources'

    print 'Add server groups WSM-CACHE-SVR WSMPM-MAN-SVR JRF-MAN-SVR to AdminServer'
    serverGroup = ["WSM-CACHE-SVR" , "WSMPM-MAN-SVR" , "JRF-MAN-SVR"]
    setServerGroups(ADMIN_SERVER_NAME, serverGroup)

    serverGroup = ["SOA-MGD-SVRS"]
    if SOA_CLUSTER:
      if WEBLOGIC_VERSION in ['12.2.1', '12.2.1.1', '12.2.1.2', '12.2.1.3']:
        cleanJMS('UMSJMSSystemResource', 'UMSJMSServer_auto', 'UMSJMSFileStore_auto')

      print 'Add server group SOA-MGD-SVRS to cluster'
      cd('/')
      setServerGroups('soa_server1', [])

      soaServers = getClusterServers(SOA_CLUSTER, ADMIN_SERVER_NAME)
      cd('/')
      for i in range(len(soaServers)):
        print "Add server group SOA-MGD-SVRS to " + soaServers[i]
        setServerGroups(soaServers[i] , serverGroup)

      print 'Assign cluster to defaultCoherenceCluster'
      cd('/')
      assign('Cluster',SOA_CLUSTER,'CoherenceClusterSystemResource','defaultCoherenceCluster')
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

      if 'soa_server1' in soaServers:
        pass
      else:
        print "delete soa_server1"
        cd('/')
        delete('soa_server1', 'Server')

      if WEBLOGIC_VERSION in ['12.2.1', '12.2.1.1', '12.2.1.2', '12.2.1.3']:
        updateDomain()
        dumpStack()

        closeDomain()
        readDomain(DOMAIN_PATH)

        cleanJMS('UMSJMSSystemResource', 'UMSJMSServer_auto', 'UMSJMSFileStore_auto')
        recreateUMSJms12c(ADMIN_SERVER_NAME, SOA_CLUSTER, OSB_CLUSTER, BAM_CLUSTER, ESS_CLUSTER, All)

    else:
      print 'Add server group SOA-MGD-SVRS to soa_server1'
      setServerGroups('soa_server1', serverGroup)

    print 'end server groups'

updateDomain()
dumpStack()

closeDomain()

print('Exiting...')
exit()
