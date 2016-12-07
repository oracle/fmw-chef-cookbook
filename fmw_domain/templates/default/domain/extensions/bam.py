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

BAM_SERVER_STARTUP_ARGUMENTS = '<%= @bam_server_startup_arguments %>'
BAM_SERVER_LISTEN_PORT       = 9001
ESS_CLUSTER                  = '<%= @ess_cluster %>'
SOA_CLUSTER                  = '<%= @soa_cluster %>'
OSB_CLUSTER                  = '<%= @osb_cluster %>'
BAM_CLUSTER                  = '<%= @bam_cluster %>'

# templates
WLS_EM_TEMPLATE        = '<%= @wls_em_template %>'
WLS_BAM_TEMPLATE       = '<%= @wls_bam_template %>'

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

print 'Adding BAM Template'
addTemplate(WLS_BAM_TEMPLATE)

if WEBLOGIC_VERSION == '10.3.6':
  cd('/')
  # destroy the normal one
  delete('LocalMachine','Machine')
  print('change the default machine LocalMachine with type Machine')
  createMachine('UnixMachine', MACHINE_NAME, ADMIN_SERVER_LISTEN_ADDRESS, NODEMANAGER_LISTEN_PORT)

print 'Change AdminServer'
cd('/Servers/'+ADMIN_SERVER_NAME)
set('Machine','LocalMachine')

if BAM_CLUSTER:
  pass
else:
  print 'change bam_server1'
  cd('/')
  changeManagedServer('bam_server1', MACHINE_NAME, ADMIN_SERVER_LISTEN_ADDRESS, BAM_SERVER_LISTEN_PORT, BAM_SERVER_STARTUP_ARGUMENTS, JAVA_HOME)

if WEBLOGIC_VERSION == '10.3.6':

  print 'Change datasources'
  changeDatasource('OraSDPMDataSource', REPOS_DBUSER_PREFIX+'_ORASDPM', REPOS_DBPASSWORD, REPOS_DBURL)
  changeDatasource('mds-owsm', REPOS_DBUSER_PREFIX+'_MDS', REPOS_DBPASSWORD, REPOS_DBURL)
  changeDatasource('BAMDataSource', REPOS_DBUSER_PREFIX+'_ORABAM', REPOS_DBPASSWORD, REPOS_DBURL)

  if BAM_CLUSTER:
    bamServers = getClusterServers(BAM_CLUSTER, ADMIN_SERVER_NAME)
    if 'bam_server1' in bamServers:
      pass
    else:
      print "delete bam_server1"
      cd('/')
      delete('bam_server1', 'Server')

    change11gFMWTargets(ADMIN_SERVER_NAME, SOA_CLUSTER, OSB_CLUSTER, BAM_CLUSTER, BPM_ENABLED)

    updateDomain()
    dumpStack()

    closeDomain()
    readDomain(DOMAIN_PATH)

    cleanJMS('BAMJmsSystemResource', 'BAMJMSServer_auto', None)

if WEBLOGIC_VERSION != '10.3.6':

    print 'Change datasources'

    print 'Change datasource LocalScvTblDataSource'
    changeDatasource('LocalSvcTblDataSource', REPOS_DBUSER_PREFIX+'_STB', REPOS_DBPASSWORD, REPOS_DBURL)

    print 'Call getDatabaseDefaults which reads the service table'
    getDatabaseDefaults()

    changeDatasourceToXA('OraSDPMDataSource')
    changeDatasourceToXA('BamDataSource')

    print 'end datasources'

    print 'Add server groups WSM-CACHE-SVR WSMPM-MAN-SVR JRF-MAN-SVR to AdminServer'
    serverGroup = ["WSM-CACHE-SVR" , "WSMPM-MAN-SVR" , "JRF-MAN-SVR"]
    setServerGroups(ADMIN_SERVER_NAME, serverGroup)

    serverGroup = ["BAM12-MGD-SVRS"]
    if BAM_CLUSTER:

      if WEBLOGIC_VERSION in ['12.2.1', '12.2.1.1', '12.2.1.2']:
        cleanJMS('UMSJMSSystemResource', 'UMSJMSServer_auto', 'UMSJMSFileStore_auto')

      print 'Add server group BAM-MGD-SVRS to cluster'
      cd('/')
      setServerGroups('bam_server1', [])

      bamServers = getClusterServers(BAM_CLUSTER, ADMIN_SERVER_NAME)
      cd('/')
      for i in range(len(bamServers)):
        print "Add server group BAM-MGD-SVRS to " + bamServers[i]
        setServerGroups(bamServers[i] , serverGroup)

      print 'Assign cluster to defaultCoherenceCluster'
      cd('/')
      assign('Cluster',BAM_CLUSTER,'CoherenceClusterSystemResource','defaultCoherenceCluster')
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

      if 'bam_server1' in bamServers:
        pass
      else:
        print "delete bam_server1"
        cd('/')
        delete('bam_server1', 'Server')

      updateDomain()
      dumpStack()

      closeDomain()
      readDomain(DOMAIN_PATH)

      if WEBLOGIC_VERSION in ['12.2.1', '12.2.1.1', '12.2.1.2']:
        cd('/')
        cleanJMS('BamCQServiceJmsSystemModule', None, None)
        cleanJMS('UMSJMSSystemResource', 'UMSJMSServer_auto', 'UMSJMSFileStore_auto')
        recreateUMSJms12c(ADMIN_SERVER_NAME, SOA_CLUSTER, OSB_CLUSTER, BAM_CLUSTER, ESS_CLUSTER, All)
        updateDomain()
        dumpStack()

        closeDomain()
        readDomain(DOMAIN_PATH)

      cleanJMS('BamCQServiceJmsSystemResource', 'BamCQServiceJmsServer', 'BamCQServiceJmsFileStore')
      updateDomain()
      dumpStack()

      closeDomain()
      readDomain(DOMAIN_PATH)

      BAMJms12c(BAM_CLUSTER)


    else:
      print 'Add server group BAM-MGD-SVRS to bam_server1'
      setServerGroups('bam_server1', serverGroup)

    print 'end server groups'

updateDomain()
dumpStack()

closeDomain()

print('Exiting...')
exit()
