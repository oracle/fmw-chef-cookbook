#
def createBootPropertiesFile(directoryPath,fileName, username, password):
  serverDir = File(directoryPath)
  bool = serverDir.mkdirs()
  fileNew=open(directoryPath + '/'+fileName, 'w')
  fileNew.write('username=%s\n' % username)
  fileNew.write('password=%s\n' % password)
  fileNew.flush()
  fileNew.close()

def createAdminStartupPropertiesFile(directoryPath, args):
  adminserverDir = File(directoryPath)
  bool = adminserverDir.mkdirs()
  fileNew=open(directoryPath + '/startup.properties', 'w')
  args=args.replace(':','\\:')
  args=args.replace('=','\\=')
  fileNew.write('Arguments=%s\n' % args)
  fileNew.flush()
  fileNew.close()

def createMachine(type, name, address, port):
  cd('/')
  create(name,type)
  cd(type + '/' + name)
  create(name, 'NodeManager')
  cd('NodeManager/' + name)
  set('NMType','SSL')
  set('ListenAddress',address)
  if port:
    set('ListenPort', port)

def changeDefaultServerAttributes(server, machine, address, port, java_arguments, java_home):
  print "changeDefaultServerAttributes for server " + server
  cd('/Servers/' + server)

  if machine:
    set('Machine', machine)
  if address:
    set('ListenAddress', address)
  if port:
    set('ListenPort', port)

  create(server, 'ServerStart')
  cd('ServerStart/' + server)
  set('Arguments' , java_arguments)
  set('JavaVendor', 'Sun')
  set('JavaHome'  , java_home)

def changeAdminServer(adminserver, machine, address, port, java_arguments, java_home):
  cd('/Servers/AdminServer')
  set('Name', adminserver )
  changeDefaultServerAttributes(adminserver, machine, address, port, java_arguments, java_home)

def changeManagedServer(server, machine, address, port, java_arguments, java_home):
  changeDefaultServerAttributes(server, machine, address, port, java_arguments, java_home)

def setWebLogicPassword(user, password):
  print('Set password...')
  cd('/')
  cd('Security/base_domain/User/weblogic')
  # weblogic user name + password
  set('Name', user)
  set('Password', password)

def changeDatasource(datasource, username, password, db_url):
  print 'Change datasource '+datasource
  cd('/')
  cd('/JDBCSystemResource/'+datasource+'/JdbcResource/'+datasource+'/JDBCDriverParams/NO_NAME_0')
  set('URL',db_url)
  set('PasswordEncrypted',password)
  cd('Properties/NO_NAME_0/Property/user')
  set('Value',username)
  cd('/')

def changeDatasourceToXA(datasource):
  print 'Change datasource '+datasource
  cd('/')
  cd('/JDBCSystemResource/'+datasource+'/JdbcResource/'+datasource+'/JDBCDriverParams/NO_NAME_0')
  set('DriverName','oracle.jdbc.xa.client.OracleXADataSource')
  set('UseXADataSourceInterface','True')
  cd('/JDBCSystemResource/'+datasource+'/JdbcResource/'+datasource+'/JDBCDataSourceParams/NO_NAME_0')
  set('GlobalTransactionsProtocol','TwoPhaseCommit')
  cd('/')

def changeDatasourceDriver(datasource, username, password, db_url, driver):
  print 'Change datasource '+datasource
  cd('/')
  cd('/JDBCSystemResource/'+datasource+'/JdbcResource/'+datasource+'/JDBCDriverParams/NO_NAME_0')
  set('URL',db_url)
  set('DriverName','oracle.jdbc.OracleDriver')
  set('PasswordEncrypted',password)
  cd('Properties/NO_NAME_0/Property/user')
  set('Value',username)
  cd('/')

def getClusterName(cluster, admin_server):
    targetServerStr = str(cluster)
    s = ls('/Server')
    print ' '
    clustername = " "
    for token in s.split("drw-"):
        token=token.strip().lstrip().rstrip()
        path="/Server/"+token
        cd(path)
        if not token == admin_server and not token == '':
            if not targetServerStr.find(token+":") == -1:
                clustername = get('Cluster')
    return clustername

def getClusterServers(cluster, admin_server):
    servers = []
    s = ls('/Server')
    clustername = " "
    for token in s.split("drw-"):
        token=token.strip().lstrip().rstrip()
        path="/Server/"+token
        cd(path)
        if not token == admin_server and not token == '':
            clustername = get('Cluster')
            searchClusterStr = cluster+":"
            clusterNameStr = str(clustername)
            if not clusterNameStr.find(searchClusterStr) == -1:
                servers.append(token)

    return servers

def getFirstClusterServer(cluster, admin_server):
    s = ls('/Server')
    clustername = " "
    for token in s.split("drw-"):
        token=token.strip().lstrip().rstrip()
        path="/Server/"+token
        cd(path)
        if not token == admin_server and not token == '':
            clustername = get('Cluster')
            searchClusterStr = cluster+":"
            clusterNameStr = str(clustername)
            if not clusterNameStr.find(searchClusterStr) == -1:
                return token


def reassignTarget(type, name, untarget, target):
  untargets = String(untarget).split(",")
  for i in range(len(untargets)):
    try:
      unassign(type, name, 'Target', untargets[i])
    except:
      print "reassignTarget unassign failed type " + type + " name " + name + " untarget " + untarget + " target " + target
      pass

  try:
    assign(type, name, 'Target', target)
  except:
    print "reassignTarget assign failed type " + type + " name " + name + " untarget " + untarget + " target " + target
    pass


def change11gFMWTargets(admin_server, soa_cluster, osb_cluster, bam_cluster, bpm_enabled):
    AllArray = []
    AdapterArray = []

    AllArray.append(admin_server)
    AdapterArray.append(admin_server)

    if soa_cluster:
      AllArray.append(soa_cluster)
      AdapterArray.append(soa_cluster)

    if bam_cluster:
      AllArray.append(bam_cluster)

    if osb_cluster:
      AllArray.append(osb_cluster)
      AdapterArray.append(osb_cluster)

    All       = ','.join(AllArray)
    Adapters  = ','.join(AdapterArray)

    reassignTarget('AppDeployment', 'DMS Application#11.1.1.1.0', All, All)
    reassignTarget('AppDeployment', 'wsil-wls', All, All)

    try:
      reassignTarget('AppDeployment', 'AqAdapter'        , All, Adapters)
      reassignTarget('AppDeployment', 'DbAdapter'        , All, Adapters)
      reassignTarget('AppDeployment', 'FileAdapter'      , All, Adapters)
      reassignTarget('AppDeployment', 'FtpAdapter'       , All, Adapters)
      reassignTarget('AppDeployment', 'JmsAdapter'       , All, Adapters)
      reassignTarget('AppDeployment', 'MQSeriesAdapter'  , All, Adapters)
      reassignTarget('AppDeployment', 'OracleAppsAdapter', All, Adapters)
      reassignTarget('AppDeployment', 'OracleBamAdapter' , All, Adapters)
      reassignTarget('AppDeployment', 'SocketAdapter'    , All, Adapters)
      if soa_cluster:
        reassignTarget('AppDeployment', 'UMSAdapter'     , All, Adapters)
    except:
      print "AppDeployment Adapters error", sys.exc_info()[0]

    reassignTarget('AppDeployment', 'em'                                     , All, admin_server)
    reassignTarget('AppDeployment', 'FMW Welcome Page Application#11.1.0.0.0', All, admin_server)

    if soa_cluster:
      try:
        reassignTarget('AppDeployment', 'b2bui'                      , All, soa_cluster)
        reassignTarget('AppDeployment', 'composer'                   , All, soa_cluster)
        reassignTarget('AppDeployment', 'DefaultToDoTaskFlow'        , All, soa_cluster)
        reassignTarget('AppDeployment', 'soa-infra'                  , All, soa_cluster)
        reassignTarget('AppDeployment', 'worklistapp'                , All, soa_cluster)
        reassignTarget('AppDeployment', 'usermessagingdriver-email'  , All, soa_cluster)
        reassignTarget('AppDeployment', 'usermessagingserver'        , All, soa_cluster)
        reassignTarget('AppDeployment', 'wsm-pm'                     , All, soa_cluster)
        if bpm_enabled == true:
          reassignTarget('AppDeployment', 'BPMComposer'                , All, soa_cluster)
          reassignTarget('AppDeployment', 'frevvo'                     , All, soa_cluster)
          reassignTarget('AppDeployment', 'OracleBPMComposerRolesApp'  , All, soa_cluster)
          reassignTarget('AppDeployment', 'OracleBPMProcessRolesApp'   , All, soa_cluster)
          reassignTarget('AppDeployment', 'OracleBPMWorkspace'         , All, soa_cluster)
          reassignTarget('AppDeployment', 'SimpleApprovalTaskFlow'     , All, soa_cluster)
      except:
        print "AppDeployment soa apps error", sys.exc_info()[0]

    if bam_cluster:
      try:
        reassignTarget('AppDeployment', 'oracle-bam#11.1.1'          , All, bam_cluster)
        reassignTarget('AppDeployment', 'usermessagingdriver-email'  , All, soa_cluster + "," + bam_cluster)
        reassignTarget('AppDeployment', 'usermessagingserver'        , All, soa_cluster + "," + bam_cluster)
        reassignTarget('AppDeployment', 'wsm-pm'                     , All, soa_cluster + "," + bam_cluster)
      except:
        print "AppDeployment bam apps error", sys.exc_info()[0]

    if osb_cluster:
      osb_server1 = getFirstClusterServer(osb_cluster, admin_server)
      try:
        reassignTarget('AppDeployment', 'ALDSP Transport Provider'                  , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'ALSB Coherence Cache Provider'             , All, osb_cluster)
        reassignTarget('AppDeployment', 'ALSB Framework Starter Application'        , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'ALSB Logging'                              , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'ALSB Publish'                              , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'ALSB Resource'                             , All, osb_cluster)
        reassignTarget('AppDeployment', 'ALSB Routing'                              , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'ALSB Subscription Listener'                , All, osb_cluster)
        reassignTarget('AppDeployment', 'ALSB Test Framework'                       , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'ALSB Transform'                            , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'ALSB UDDI Manager'                         , All, admin_server)
        reassignTarget('AppDeployment', 'ALSB WSIL'                                 , All, osb_cluster)
        reassignTarget('AppDeployment', 'BPEL 10g Transport Provider'               , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'EJB Transport Provider'                    , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'FLOW Transport Provider'                   , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'JCA Transport Provider'                    , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'JEJB Transport Provider'                   , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'JMS Reporting Provider'                    , All, osb_cluster)
        reassignTarget('AppDeployment', 'MQ Transport Provider'                     , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'SB Transport Provider'                     , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'ServiceBus_Console'                        , All, admin_server)
        reassignTarget('AppDeployment', 'SOA-DIRECT Transport Provider'             , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'Tuxedo Transport Provider'                 , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'WS Transport Async Applcation'             , All, osb_cluster)
        reassignTarget('AppDeployment', 'WS Transport Provider'                     , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment', 'XBus Kernel'                               , All, osb_cluster + "," + admin_server)

        reassignTarget('AppDeployment', 'ALSB Cluster Singleton Marker Application' , All, osb_server1)
        reassignTarget('AppDeployment', 'ALSB Domain Singleton Marker Application'  , All, osb_server1)
        reassignTarget('AppDeployment', 'Message Reporting Purger'                  , All, osb_server1)

        reassignTarget('AppDeployment', 'Email Transport Provider'                                  , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment.SubDeployment', 'Email Transport Provider.emailtransport.jar' , All, osb_cluster)
        reassignTarget('AppDeployment', 'File Transport Provider'                                   , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment.SubDeployment', 'File Transport Provider.filepoll.jar'        , All, osb_cluster)
        reassignTarget('AppDeployment', 'Ftp Transport Provider'                                    , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment.SubDeployment', 'Ftp Transport Provider.ftp_transport.jar'    , All, osb_cluster)
        reassignTarget('AppDeployment', 'SFTP Transport Provider'                                   , All, osb_cluster + "," + admin_server)
        reassignTarget('AppDeployment.SubDeployment', 'SFTP Transport Provider.sftp_transport.jar'  , All, osb_cluster)
      except:
        print "AppDeployment osb apps error", sys.exc_info()[0]

    reassignTarget('Library', 'emai'                                   , All, admin_server)
    reassignTarget('Library', 'oracle.webcenter.skin#11.1.1@11.1.1'    , All, admin_server)
    reassignTarget('Library', 'oracle.webcenter.composer#11.1.1@11.1.1', All, admin_server)
    reassignTarget('Library', 'emas'                                   , All, admin_server)
    reassignTarget('Library', 'emcore'                                 , All, admin_server)

    reassignTarget('Library', 'adf.oracle.businesseditor#1.0@11.1.1.2.0'  , All, All)
    reassignTarget('Library', 'adf.oracle.domain#1.0@11.1.1.2.0'          , All, All)
    reassignTarget('Library', 'adf.oracle.domain.webapp#1.0@11.1.1.2.0'   , All, All)

    reassignTarget('Library', 'jsf#1.2@1.2.9.0' , All, All)
    reassignTarget('Library', 'jstl#1.2@1.2.0.1', All, All)
    reassignTarget('Library', 'ohw-rcf#5@5.0'   , All, All)
    reassignTarget('Library', 'ohw-uix#5@5.0'   , All, All)

    reassignTarget('Library', 'oracle.adf.desktopintegration.model#1.0@11.1.1.2.0', All, All)
    reassignTarget('Library', 'oracle.adf.desktopintegration#1.0@11.1.1.2.0'      , All, All)
    reassignTarget('Library', 'oracle.adf.dconfigbeans#1.0@11.1.1.2.0'            , All, All)
    reassignTarget('Library', 'oracle.adf.management#1.0@11.1.1.2.0'              , All, All)

    reassignTarget('Library', 'oracle.bi.jbips#11.1.1@0.1'                 , All, All)
    reassignTarget('Library', 'oracle.bi.composer#11.1.1@0.1'              , All, All)
    reassignTarget('Library', 'oracle.bi.adf.model.slib#1.0@11.1.1.2.0'    , All, All)
    reassignTarget('Library', 'oracle.bi.adf.view.slib#1.0@11.1.1.2.0'     , All, All)
    reassignTarget('Library', 'oracle.bi.adf.webcenter.slib#1.0@11.1.1.2.0', All, All)

    reassignTarget('Library', 'oracle.dconfig-infra#11@11.1.1.1.0'   , All, All)
    reassignTarget('Library', 'oracle.jrf.system.filter'             , All, All)
    reassignTarget('Library', 'oracle.jsp.next#11.1.1@11.1.1'        , All, All)
    reassignTarget('Library', 'oracle.pwdgen#11.1.1@11.1.1.2.0'      , All, All)

    reassignTarget('Library', 'oracle.wsm.seedpolicies#11.1.1@11.1.1', All, All)
    reassignTarget('Library', 'orai18n-adf#11@11.1.1.1.0'            , All, All)
    reassignTarget('Library', 'UIX#11@11.1.1.1.0'                    , All, All)

    if bam_cluster:
      try:
        reassignTarget('Library', 'oracle.sdp.client#11.1.1@11.1.1'                , All, soa_cluster + "," + bam_cluster)
        reassignTarget('Library', 'oracle.rules#11.1.1@11.1.1'                     , All, soa_cluster + "," + bam_cluster + "," + admin_server)
        reassignTarget('Library', 'oracle.soa.rules_dict_dc.webapp#11.1.1@11.1.1'  , All, soa_cluster + "," + bam_cluster)
      except:
        print "Library bam libs error", sys.exc_info()[0]
    elif soa_cluster:
      try:
        reassignTarget('Library', 'oracle.sdp.client#11.1.1@11.1.1'                , All, soa_cluster)
        reassignTarget('Library', 'oracle.rules#11.1.1@11.1.1'                     , All, soa_cluster + "," + admin_server)
        reassignTarget('Library', 'oracle.soa.rules_dict_dc.webapp#11.1.1@11.1.1'  , All, soa_cluster)
      except:
        print "Library soa libs error", sys.exc_info()[0]
        dumpStack()

    if soa_cluster:
      try:
        reassignTarget('Library', 'oracle.sdp.messaging#11.1.1@11.1.1'             , All, All)
        reassignTarget('Library', 'oracle.applcore.config#0.1@11.1.1.0.0'          , All, soa_cluster)
        reassignTarget('Library', 'oracle.applcore.model#0.1@11.1.1.0.0'           , All, soa_cluster)
        reassignTarget('Library', 'oracle.applcore.view#0.1@11.1.1.0.0'            , All, soa_cluster)
        reassignTarget('Library', 'oracle.bpm.mgmt#11.1.1@11.1.1'                  , All, soa_cluster + "," + admin_server)
        reassignTarget('Library', 'oracle.soa.bpel#11.1.1@11.1.1'                  , All, soa_cluster)
        reassignTarget('Library', 'oracle.soa.composer.webapp#11.1.1@11.1.1'       , All, soa_cluster)
        reassignTarget('Library', 'oracle.soa.ext#11.1.1@11.1.1'                   , All, soa_cluster)
        reassignTarget('Library', 'oracle.soa.mediator#11.1.1@11.1.1'              , All, soa_cluster)
        reassignTarget('Library', 'oracle.soa.worklist#11.1.1@11.1.1'              , All, soa_cluster)

        reassignTarget('Library', 'oracle.soa.workflow.wc#11.1.1@11.1.1'           , All, soa_cluster)
        reassignTarget('Library', 'oracle.soa.worklist.webapp#11.1.1@11.1.1'       , All, soa_cluster)
        reassignTarget('Library', 'oracle.soa.rules_editor_dc.webapp#11.1.1@11.1.1', All, soa_cluster)
        reassignTarget('Library', 'oracle.soa.workflow#11.1.1@11.1.1'              , All, soa_cluster)
        if bpm_enabled == true:
          reassignTarget('Library', 'oracle.bpm.client#11.1.1@11.1.1'        , All, soa_cluster + "," + admin_server)
          reassignTarget('Library', 'oracle.bpm.composerlib#11.1.1@11.1.1'   , All, soa_cluster + "," + admin_server)
          reassignTarget('Library', 'oracle.bpm.projectlib#11.1.1@11.1.1'    , All, soa_cluster + "," + admin_server)
          reassignTarget('Library', 'oracle.bpm.runtime#11.1.1@11.1.1'       , All, soa_cluster + "," + admin_server)
          reassignTarget('Library', 'oracle.bpm.webapp.common#11.1.1@11.1.1' , All, soa_cluster + "," + admin_server)
          reassignTarget('Library', 'oracle.bpm.workspace#11.1.1@11.1.1'     , All, soa_cluster + "," + admin_server)
      except:
        print "Library soa libs error", sys.exc_info()[0]
        dumpStack()

    if bam_cluster:
      try:
        reassignTarget('Library', 'oracle.bam.library#11.1.1@11.1.1'       , All, bam_cluster + "," + admin_server)
      except:
        print "Library bam libs error", sys.exc_info()[0]

    if osb_cluster:
      try:
        reassignTarget('Library', 'oracle.jrf.coherence#3@11.1.1'                   , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'coherence-l10n#11.1.1@11.1.1'                    , All, osb_cluster)
        reassignTarget('Library', 'ftptransport-l10n#2.5@2.5'                       , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'sftptransport-l10n#3.0@3.0'                      , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'emailtransport-l10n#2.5@2.5'                     , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'filetransport-l10n#2.5@2.5'                      , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'mqtransport-l10n#3.0@3.0'                        , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'mqconnection-l10n#3.0@3.0'                       , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'ejbtransport-l10n#2.5@2.5'                       , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'tuxedotransport-l10n#2.5@2.5'                    , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'aldsp_transport-l10n#3.0@3.0'                    , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'wstransport-l10n#2.6@2.6'                        , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'flow-transport-l10n#3.0@3.0'                     , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'bpel10gtransport-l10n#3.1@3.1'                   , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'jcatransport-l10n#3.1@3.1'                       , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'wsif#11.1.1@11.1.1'                              , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'JCAFrameworkImpl#11.1.1@11.1.1'                  , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'jejbtransport-l10n#3.2@3.2'                      , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'jejbtransport-jar#3.2@3.2'                       , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'soatransport-l10n#11.1.1.2.0@11.1.1.2.0'         , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'stage-utils#2.5@2.5'                             , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'sbconsole-l10n#2.5@2.5'                          , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'xbusrouting-l10n#2.5@2.5'                        , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'xbustransform-l10n#2.5@2.5'                      , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'xbuspublish-l10n#2.5@2.5'                        , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'xbuslogging-l10n#2.5@2.5'                        , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'testfwk-l10n#2.5@2.5'                            , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'com.bea.wlp.lwpf.console.app#10.3.0@10.3.0'      , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'com.bea.wlp.lwpf.console.web#10.3.0@10.3.0'      , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'wlp-lookandfeel-web-lib#10.3.0@10.3.0'           , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'wlp-light-web-lib#10.3.0@10.3.0'                 , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'wlp-framework-common-web-lib#10.3.0@10.3.0'      , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'wlp-framework-struts-1.2-web-lib#10.3.0@10.3.0'  , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'struts-1.2#1.2@1.2.9'                            , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'beehive-netui-1.0.1-10.0#1.0@1.0.2.2'            , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'beehive-netui-resources-1.0.1-10.0#1.0@1.0.2.2'  , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'beehive-controls-1.0.1-10.0-war#1.0@1.0.2.2'     , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'weblogic-controls-10.0-war#10.0@10.2'            , All, osb_cluster + "," + admin_server)
        reassignTarget('Library', 'wls-commonslogging-bridge-war#1.0@1.1'           , All, osb_cluster + "," + admin_server)
      except:
        print "Library osb libs error", sys.exc_info()[0]

    reassignTarget('ShutdownClass', 'JOC-Shutdown'                                      , All, All)
    reassignTarget('ShutdownClass', 'DMSShutdown'                                       , All, All)

    reassignTarget('StartupClass' , 'JRF Startup Class'                                 , All, All)
    reassignTarget('StartupClass' , 'JPS Startup Class'                                 , All, All)
    reassignTarget('StartupClass' , 'ODL-Startup'                                       , All, All)
    reassignTarget('StartupClass' , 'AWT Application Context Startup Class'             , All, All)
    reassignTarget('StartupClass' , 'JMX Framework Startup Class'                       , All, All)
    reassignTarget('StartupClass' , 'Web Services Startup Class'                        , All, All)
    reassignTarget('StartupClass' , 'JOC-Startup'                                       , All, All)
    reassignTarget('StartupClass' , 'DMS-Startup'                                       , All, All)

    if soa_cluster:
      try:
        reassignTarget('StartupClass' , 'SOAStartupClass'                                , All, soa_cluster)
      except:
        print "StartupClass soa class error", sys.exc_info()[0]

    if osb_cluster:
      try:
        reassignTarget('StartupClass' , 'OSB JCA Transport Post-Activation Startup Class', All, osb_cluster + "," + admin_server)
      except:
        print "StartupClass osb class error", sys.exc_info()[0]

    reassignTarget('WldfSystemResource', 'Module-FMWDFW'       , All, All)

    if soa_cluster:
      try:
        reassignTarget('JdbcSystemResource', 'EDNDataSource'       , All, soa_cluster)
        reassignTarget('JdbcSystemResource', 'EDNLocalTxDataSource', All, soa_cluster)
        reassignTarget('JdbcSystemResource', 'mds-soa'             , All, soa_cluster + "," + admin_server)
        reassignTarget('JdbcSystemResource', 'mds-owsm'            , All, All)
        reassignTarget('JdbcSystemResource', 'SOADataSource'       , All, soa_cluster)
        reassignTarget('JdbcSystemResource', 'SOALocalTxDataSource', All, soa_cluster)
      except:
        print "JdbcSystemResource soa jdbc error", sys.exc_info()[0]

    if bam_cluster:
      try:
        reassignTarget('JdbcSystemResource', 'BAMDataSource'       , All, bam_cluster)
        reassignTarget('JdbcSystemResource', 'OraSDPMDataSource'   , All, soa_cluster + "," + bam_cluster)
      except:
        print "JdbcSystemResource bam jdbc error", sys.exc_info()[0]
    elif soa_cluster:
      try:
        reassignTarget('JdbcSystemResource', 'OraSDPMDataSource'   , All, soa_cluster)
      except:
        print "JdbcSystemResource soa jdbc error", sys.exc_info()[0]

    if osb_cluster:
      try:
        reassignTarget('JdbcSystemResource', 'wlsbjmsrpDataSource' , All, osb_cluster + "," + admin_server)
      except:
        print "JdbcSystemResource osb jdbc error", sys.exc_info()[0]

def cleanJMS(jms_module_pattern, jms_server_pattern, filestore_pattern):
  if jms_module_pattern:
    s = ls('/JMSSystemResources')
    for token in s.split("drw-"):
      token=token.strip().lstrip().rstrip()
      if not token == '' and not token.find(jms_module_pattern) == -1:
        print "token "+token
        try:
          delete(token, 'JMSSystemResource')
        except:
          print "delete of " + token + " jmsmodule failed", sys.exc_info()[0]
          pass

  if jms_server_pattern:
    s = ls('/JMSServers')
    for token in s.split("drw-"):
      token=token.strip().lstrip().rstrip()
      if not token == '' and not token.find(jms_server_pattern) == -1:
        print "token "+token
        try:
          delete(token, 'JMSServer')
        except:
          print "delete of " + token + " jmsserver failed", sys.exc_info()[0]
          pass

  if filestore_pattern:
    s = ls('/FileStore')
    for token in s.split("drw-"):
      token=token.strip().lstrip().rstrip()
      if not token == '' and not token.find(filestore_pattern) == -1:
        print "token "+token
        try:
          delete(token, 'FileStore')
        except:
          print "delete of " + token + " filestore failed", sys.exc_info()[0]
          pass

def cleanSAFagents(saf_agent_pattern):
  if saf_agent_pattern:
    s = ls('/SAFAgent')
    for token in s.split("drw-"):
      token=token.strip().lstrip().rstrip()
      if not token == '' and not token.find(saf_agent_pattern) == -1:
        print "token "+token
        try:
          delete(token, 'SAFAgent')
        except:
          print "delete of " + token + " safagent failed", sys.exc_info()[0]
          pass

def createFileStore(storeName, serverName):
    create(storeName, 'FileStore')
    cd('/FileStore/'+storeName)
    set ('Target', serverName)
    set ('Directory', storeName)
    cd('/')


def createJMSServers(cluster, track, currentServerCnt):
  print ' '
  print "Creating JMS Servers for the cluster :- ", cluster
  s = ls('/Server')
  print ' '
  clustername = " "
  serverCnt = currentServerCnt
  for token in s.split("drw-"):
    token=token.strip().lstrip().rstrip()
    path="/Server/"+token
    cd(path)
    if not token == 'AdminServer' and not token == '':
      clustername = get('Cluster')
      print "Cluster Associated with the Server [",token,"] :- ",clustername
      print ' '
      searchClusterStr = cluster+":"
      clusterNameStr = str(clustername)
      print "searchClusterStr = ",searchClusterStr
      print "clusterNameStr = ",clusterNameStr
      if not clusterNameStr.find(searchClusterStr) == -1:
        print token, " is associated with ", cluster
        print ' '
        print "Creating JMS Servers for ", track
        print ' '
        cd('/')

        if track == 'bpm':
          jmsServerName = 'BPMJMSServer_auto_'+str(serverCnt)
          fileStoreName = 'BPMJMSServerFileStore_auto_'+str(serverCnt)
        elif track == 'ag':
          jmsServerName = 'AGJMSServer_auto_'+str(serverCnt)
          fileStoreName = 'AGJMSServerFileStore_auto_'+str(serverCnt)
        elif track == 'ps6soa':
          jmsServerName = 'PS6SOAJMSServer_auto_'+str(serverCnt)
          fileStoreName = 'PS6SOAJMSServerFileStore_auto_'+str(serverCnt)

        createFileStore(fileStoreName, token)
        print "Created File Store :- ", fileStoreName

        create(jmsServerName, 'JMSServer')
        print "Created JMS Server :- ", jmsServerName
        print ' '
        assign('JMSServer', jmsServerName, 'Target', token)
        print jmsServerName, " assigned to server :- ", token
        print ' '
        cd('/JMSServer/'+jmsServerName)
        set ('PersistentStore', fileStoreName)

        serverCnt = serverCnt + 1


def soa11g_bpm(cluster, bpm_enabled):
  createJMSServers(cluster, 'bpm', 1)

  cd('/')
  create('BPMJMSModuleUDDs','JMSSystemResource')

  cd('/')
  cd('JMSSystemResource/BPMJMSModuleUDDs')
  assign('JMSSystemResource', 'BPMJMSModuleUDDs', 'Target', cluster)

  cd('/')
  cd('JMSSystemResource/BPMJMSModuleUDDs')
  create('BPMJMSSubDM', 'SubDeployment')

  cd('/')
  cd('JMSSystemResource/BPMJMSModuleUDDs/SubDeployments/BPMJMSSubDM')

  print ' '
  print ("*** Listing SOA JMS Servers ***")
  s = ls('/JMSServers')
  soaJMSServerStr=''
  for token in s.split("drw-"):
      token=token.strip().lstrip().rstrip()
      if not token.find("BPMJMSServer_auto") == -1:
          soaJMSServerStr = soaJMSServerStr + token +","
      print token

  print ("*** Setting JMS SubModule for SOA JMS Server's target***")
  assign('JMSSystemResource.SubDeployment', 'BPMJMSModuleUDDs.BPMJMSSubDM', 'Target', soaJMSServerStr) 

  cd('/')
  cd('JMSSystemResource/BPMJMSModuleUDDs/JmsResource/NO_NAME_0')

  udd=create('MeasurementTopic','UniformDistributedTopic')
  udd.setJNDIName('jms/bpm/MeasurementTopic')
  udd.setJMSCreateDestinationIdentifier('jms/bpm/MeasurementTopic')
  udd.setSubDeploymentName('BPMJMSSubDM')

  udd=create('PeopleQueryTopic','UniformDistributedTopic')
  udd.setJNDIName('jms/bpm/PeopleQueryTopic')
  udd.setJMSCreateDestinationIdentifier('jms/bpm/PeopleQueryTopic')
  udd.setSubDeploymentName('BPMJMSSubDM')

  soacf=create('BAMCommandXAConnectionFactory','ConnectionFactory')
  soacf.setJNDIName('jms/bpm/BAMCommandXAConnectionFactory')
  cd('/JMSSystemResource/BPMJMSModuleUDDs/JmsResource/NO_NAME_0/ConnectionFactory/BAMCommandXAConnectionFactory')
  set('DefaultTargetingEnabled', 'true')
  create('TransactionParams', 'TransactionParams')
  cd('TransactionParams/NO_NAME_0')
  cmo.setXAConnectionFactoryEnabled(true)

  cd('/')
  cd('JMSSystemResource/BPMJMSModuleUDDs/JmsResource/NO_NAME_0')

  soacf=create('CubeCommandXAConnectionFactory','ConnectionFactory')
  soacf.setJNDIName('jms/bpm/CubeCommandXAConnectionFactory')
  cd('/JMSSystemResource/BPMJMSModuleUDDs/JmsResource/NO_NAME_0/ConnectionFactory/CubeCommandXAConnectionFactory')
  set('DefaultTargetingEnabled', 'true')
  create('TransactionParams', 'TransactionParams')
  cd('TransactionParams/NO_NAME_0')
  cmo.setXAConnectionFactoryEnabled(true)

  cd('/')
  cd('JMSSystemResource/BPMJMSModuleUDDs/JmsResource/NO_NAME_0')

  soacf=create('MeasurementTopicConnectionFactory','ConnectionFactory')
  soacf.setJNDIName('jms/bpm/MeasurementTopicConnectionFactory')
  cd('/JMSSystemResource/BPMJMSModuleUDDs/JmsResource/NO_NAME_0/ConnectionFactory/MeasurementTopicConnectionFactory')
  set('DefaultTargetingEnabled', 'true')
  create('TransactionParams', 'TransactionParams')
  cd('TransactionParams/NO_NAME_0')
  cmo.setXAConnectionFactoryEnabled(true)

  cd('/')
  cd('JMSSystemResource/BPMJMSModuleUDDs/JmsResource/NO_NAME_0')

  soacf=create('PeopleQueryConnectionFactory','ConnectionFactory')
  soacf.setJNDIName('jms/bpm/PeopleQueryConnectionFactory')
  cd('/JMSSystemResource/BPMJMSModuleUDDs/JmsResource/NO_NAME_0/ConnectionFactory/PeopleQueryConnectionFactory')
  set('DefaultTargetingEnabled', 'true')
  create('TransactionParams', 'TransactionParams')
  cd('TransactionParams/NO_NAME_0')
  cmo.setXAConnectionFactoryEnabled(true)

  cd('/')
  cd('JMSSystemResource/BPMJMSModuleUDDs/JmsResource/NO_NAME_0')

  soacf=create('PeopleQueryTopicConnectionFactory','ConnectionFactory')
  soacf.setJNDIName('jms/bpm/PeopleQueryTopicConnectionFactory')
  cd('/JMSSystemResource/BPMJMSModuleUDDs/JmsResource/NO_NAME_0/ConnectionFactory/PeopleQueryTopicConnectionFactory')
  set('DefaultTargetingEnabled', 'true')
  create('TransactionParams', 'TransactionParams')
  cd('TransactionParams/NO_NAME_0')
  cmo.setXAConnectionFactoryEnabled(true)

  if bpm_enabled == true:
    cd('/')
    cleanJMS('AGJMSModule', 'AGJMSServer_auto', 'AGJMSFileStore_auto')

    createJMSServers(cluster, 'ag', 1)
    cd('/')
    create('AGJMSModuleUDDs','JMSSystemResource')

    cd('/')
    cd('JMSSystemResource/AGJMSModuleUDDs')
    assign('JMSSystemResource', 'AGJMSModuleUDDs', 'Target', cluster)

    cd('/')
    cd('JMSSystemResource/AGJMSModuleUDDs')
    create('AGJMSSubDM', 'SubDeployment')

    cd('/')
    cd('JMSSystemResource/AGJMSModuleUDDs/SubDeployments/AGJMSSubDM')

    print ' '
    print ("*** Listing SOA JMS Servers ***")
    s = ls('/JMSServers')
    soaJMSServerStr=''
    for token in s.split("drw-"):
      token=token.strip().lstrip().rstrip()
      if not token.find("AGJMSServer_auto") == -1:
        soaJMSServerStr = soaJMSServerStr + token +","
      print token

    print ("*** Setting JMS SubModule for SOA JMS Server's target***")
    assign('JMSSystemResource.SubDeployment', 'AGJMSModuleUDDs.AGJMSSubDM', 'Target', soaJMSServerStr) 

    cd('/')
    cd('JMSSystemResource/AGJMSModuleUDDs/JmsResource/NO_NAME_0')

    udd=create('UIBrokerTopic','UniformDistributedTopic')
    udd.setJNDIName('jms/bpm/UIBrokerTopic')
    udd.setJMSCreateDestinationIdentifier('jms/bpm/UIBrokerTopic')
    udd.setSubDeploymentName('AGJMSSubDM')

    soacf=create('UIBrokerTopicConnectionFactory','ConnectionFactory')
    soacf.setJNDIName('jms/bpm/UIBrokerTopicConnectionFactory')
    cd('/JMSSystemResource/AGJMSModuleUDDs/JmsResource/NO_NAME_0/ConnectionFactory/UIBrokerTopicConnectionFactory')
    set('DefaultTargetingEnabled', 'true')
    create('TransactionParams', 'TransactionParams')
    cd('TransactionParams/NO_NAME_0')
    cmo.setXAConnectionFactoryEnabled(true)

def soa11g_ps6(cluster):
  cd('/')
  createJMSServers(cluster, 'ps6soa', 1)
  cd('/')
  create('PS6SOAJMSModuleUDDs','JMSSystemResource')
  cd('/')
  cd('JMSSystemResource/PS6SOAJMSModuleUDDs')
  assign('JMSSystemResource', 'PS6SOAJMSModuleUDDs', 'Target', cluster)
  cd('/')
  cd('JMSSystemResource/PS6SOAJMSModuleUDDs')
  create('PS6SOAJMSSubDM', 'SubDeployment')
  cd('/')
  cd('JMSSystemResource/PS6SOAJMSModuleUDDs/SubDeployments/PS6SOAJMSSubDM')

  print ' '
  print ("*** Listing SOA JMS Servers ***")
  s = ls('/JMSServers')
  soaJMSServerStr=''
  for token in s.split("drw-"):
      token=token.strip().lstrip().rstrip()
      if not token.find("PS6SOAJMSServer_auto") == -1:
          soaJMSServerStr = soaJMSServerStr + token +","
      print token

  print ("*** Setting JMS SubModule for SOA JMS Server's target***")
  assign('JMSSystemResource.SubDeployment', 'PS6SOAJMSModuleUDDs.PS6SOAJMSSubDM', 'Target', soaJMSServerStr)
  cd('/')
  cd('JMSSystemResource/PS6SOAJMSModuleUDDs/JmsResource/NO_NAME_0')

  udd=create('CaseEventQueue','UniformDistributedQueue')
  udd.setJNDIName('jms/bpm/CaseEventQueue')
  udd.setJMSCreateDestinationIdentifier('jms/bpm/CaseEventQueue')
  udd.setSubDeploymentName('PS6SOAJMSSubDM')

  soacf=create('CaseEventConnectionFactory','ConnectionFactory')
  soacf.setJNDIName('jms/bpm/CaseEventConnectionFactory')
  cd('/JMSSystemResource/PS6SOAJMSModuleUDDs/JmsResource/NO_NAME_0/ConnectionFactory/CaseEventConnectionFactory')
  set('DefaultTargetingEnabled', 'true')
  create('TransactionParams', 'TransactionParams')
  cd('TransactionParams/NO_NAME_0')
  cmo.setXAConnectionFactoryEnabled(true)


def createJMSServersSB(cluster, track, currentServerCnt):
  print ' '
  print "Creating JMS Servers for the cluster :- ", cluster
  s = ls('/Server')
  print ' '
  clustername = " "
  serverCnt = currentServerCnt
  for token in s.split("drw-"):
      token=token.strip().lstrip().rstrip()
      path="/Server/"+token
      cd(path)
      if not token == 'AdminServer' and not token == '':
          clustername = get('Cluster')
          print "Cluster Associated with the Server [",token,"] :- ",clustername
          print ' '
          searchClusterStr = cluster+":"
          clusterNameStr = str(clustername)
          print "searchClusterStr = ",searchClusterStr
          print "clusterNameStr = ",clusterNameStr
          if not clusterNameStr.find(searchClusterStr) == -1:
              print token, " is associated with ", cluster
              print ' '
              print "Creating JMS Servers for ", track
              print ' '
              cd('/')

              if track == 'osb':
                  jmsServerName = 'wlsbJMSServer_auto_'+str(serverCnt)
                  fileStoreName = 'FileStore_auto_'+str(serverCnt)
              elif track == 'wsee':
                  jmsServerName = 'WseeJmsServer_auto_'+str(serverCnt)
                  fileStoreName = 'WseeFileStore_auto_'+str(serverCnt)

              createFileStore(fileStoreName, token)
              print "Created File Store :- ", fileStoreName

              create(jmsServerName, 'JMSServer')
              print "Created JMS Server :- ", jmsServerName
              print ' '
              assign('JMSServer', jmsServerName, 'Target', token)
              print jmsServerName, " assigned to server :- ", token
              print ' '
              cd('/JMSServer/'+jmsServerName)
              set ('PersistentStore', fileStoreName)

              # if track == 'wsee':
              #     safAgent     = 'ReliableWseeSAFAgent_auto_'+str(serverCnt)

              #     cd('/')
              #     create(safAgent, 'SAFAgent')
              #     cd('/SAFAgent/'+safAgent)
              #     set ('Target'     , token)
              #     set ('Store'      , fileStoreName)
              #     set ('ServiceType','Both')

              serverCnt = serverCnt + 1

def sb11g(cluster):
  cd('/')
  create('jmsResourcesUDDs','JMSSystemResource')

  cd('/')
  cd('JMSSystemResource/jmsResourcesUDDs')
  assign('JMSSystemResource', 'jmsResourcesUDDs', 'Target', cluster)

  cd('/')
  cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')

  udd=create('dist_QueueIn_auto'                                 ,'DistributedQueue')
  udd.setJNDIName("QueueIn")
  udd=create('dist_wli.reporting.jmsprovider.queue_auto'         ,'DistributedQueue')
  udd.setJNDIName("wli.reporting.jmsprovider.queue")
  udd=create('dist_wli.reporting.jmsprovider_error.queue_auto'   ,'DistributedQueue')
  udd.setJNDIName("wli.reporting.jmsprovider_error.queue")
  udd=create('dist_wlsb.internal.transport.task.queue.email_auto','DistributedQueue')
  udd.setJNDIName("wlsb.internal.transport.task.queue.email")
  udd=create('dist_wlsb.internal.transport.task.queue.file_auto' ,'DistributedQueue')
  udd.setJNDIName("wlsb.internal.transport.task.queue.file")
  udd=create('dist_wlsb.internal.transport.task.queue.ftp_auto'  ,'DistributedQueue')
  udd.setJNDIName("wlsb.internal.transport.task.queue.ftp")
  udd=create('dist_wlsb.internal.transport.task.queue.sftp_auto' ,'DistributedQueue')
  udd.setJNDIName("wlsb.internal.transport.task.queue.sftp")

  createJMSServersSB(cluster, 'osb', 1)

  print ' '
  print ("*** Listing OSB JMS Servers ***")
  s = ls('/JMSServers')
  osbJMSServerStr=''
  serverCnt =  1
  for token in s.split("drw-"):
    token=token.strip().lstrip().rstrip()
    if not token.find("wlsbJMSServer_auto") == -1:
      print token
      cd('/')
      cd('JMSSystemResource/jmsResourcesUDDs')
      subDeploymentStr = 'wlsbJMSServer'+str(serverCnt)+'_sub'
      create(subDeploymentStr, 'SubDeployment')

      cd('/')
      cd('JMSSystemResource/jmsResourcesUDDs/SubDeployments/'+subDeploymentStr)
      assign('JMSSystemResource.SubDeployment', 'jmsResourcesUDDs.'+subDeploymentStr, 'Target', token) 


      cd('/')
      cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')

      queue1 = 'QueueIn_auto_'+str(serverCnt)
      udd=create(queue1,'Queue')
      udd.setJNDIName(queue1)
      udd.setSubDeploymentName(subDeploymentStr)
      cd ('Queue')
      cd (queue1)
      #dpo = create('dpoName','DeliveryParamsOverrides')
      #dpo.setRedeliveryDelay(15*60*1000)
      dfp = create('dfpName', 'DeliveryFailureParams')
      dfp.setRedeliveryLimit(2)
      dfp.setExpirationPolicy('Discard')

      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_QueueIn_auto')
      aaa = create(queue1,'DistributedQueueMember')
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_QueueIn_auto/DistributedQueueMember/' + queue1)
      set('Weight',1)

      cd('/')
      cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')

      errorQueue = 'wli.reporting.jmsprovider_error.queue_auto_'+str(serverCnt)
      uddErr=create(errorQueue,'Queue')
      uddErr.setJNDIName(errorQueue)
      uddErr.setSubDeploymentName(subDeploymentStr)
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wli.reporting.jmsprovider_error.queue_auto')
      aaa = create(errorQueue,'DistributedQueueMember')
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wli.reporting.jmsprovider_error.queue_auto/DistributedQueueMember/' + errorQueue)
      set('Weight',1)

      cd('/')
      cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')

      reportingQueue = 'wli.reporting.jmsprovider.queue_auto_'+str(serverCnt)
      udd=create(reportingQueue,'Queue')
      udd.setJNDIName(reportingQueue)
      udd.setSubDeploymentName(subDeploymentStr)
      cd ('Queue')
      cd (reportingQueue)
      dfp = create('dfpName', 'DeliveryFailureParams')
      dfp.setRedeliveryLimit(2)
      dfp.setExpirationPolicy('Redirect')
      dfp.setErrorDestination(uddErr)
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wli.reporting.jmsprovider.queue_auto')
      aaa = create(reportingQueue,'DistributedQueueMember')
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wli.reporting.jmsprovider.queue_auto/DistributedQueueMember/' + reportingQueue)
      set('Weight',1)

      cd('/')
      cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')

      emailQueue = 'wlsb.internal.transport.task.queue.email_auto_'+str(serverCnt)
      udd=create(emailQueue,'Queue')
      udd.setJNDIName(emailQueue)
      udd.setSubDeploymentName(subDeploymentStr)
      cd ('Queue')
      cd (emailQueue)
      dfp = create('dfpName', 'DeliveryFailureParams')
      dfp.setRedeliveryLimit(2)
      dfp.setExpirationPolicy('Discard')
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wlsb.internal.transport.task.queue.email_auto')
      aaa = create(emailQueue,'DistributedQueueMember')
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wlsb.internal.transport.task.queue.email_auto/DistributedQueueMember/' + emailQueue)
      set('Weight',1)


      cd('/')
      cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')

      fileQueue = 'wlsb.internal.transport.task.queue.file_auto_'+str(serverCnt)
      udd=create(fileQueue,'Queue')
      udd.setJNDIName(fileQueue)
      udd.setSubDeploymentName(subDeploymentStr)
      cd ('Queue')
      cd (fileQueue)
      dfp = create('dfpName', 'DeliveryFailureParams')
      dfp.setRedeliveryLimit(2)
      dfp.setExpirationPolicy('Discard')
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wlsb.internal.transport.task.queue.file_auto')
      aaa = create(fileQueue,'DistributedQueueMember')
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wlsb.internal.transport.task.queue.file_auto/DistributedQueueMember/' + fileQueue)
      set('Weight',1)

      cd('/')
      cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')

      ftpQueue = 'wlsb.internal.transport.task.queue.ftp_auto_'+str(serverCnt)
      udd=create(ftpQueue,'Queue')
      udd.setJNDIName(ftpQueue)
      udd.setSubDeploymentName(subDeploymentStr)
      cd ('Queue')
      cd (ftpQueue)
      dfp = create('dfpName', 'DeliveryFailureParams')
      dfp.setRedeliveryLimit(2)
      dfp.setExpirationPolicy('Discard')
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wlsb.internal.transport.task.queue.ftp_auto')
      aaa = create(ftpQueue,'DistributedQueueMember')
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wlsb.internal.transport.task.queue.ftp_auto/DistributedQueueMember/' + ftpQueue)
      set('Weight',1)

      cd('/')
      cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')

      sftpQueue = 'wlsb.internal.transport.task.queue.sftp_auto_'+str(serverCnt)
      udd=create(sftpQueue,'Queue')
      udd.setJNDIName(sftpQueue)
      udd.setSubDeploymentName(subDeploymentStr)
      cd ('Queue')
      cd (sftpQueue)
      dfp = create('dfpName', 'DeliveryFailureParams')
      dfp.setRedeliveryLimit(2)
      dfp.setExpirationPolicy('Discard')
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wlsb.internal.transport.task.queue.sftp_auto')
      aaa = create(sftpQueue,'DistributedQueueMember')
      cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/DistributedQueue/dist_wlsb.internal.transport.task.queue.sftp_auto/DistributedQueueMember/' + sftpQueue)
      set('Weight',1)

      serverCnt = serverCnt + 1


  cd('/')
  cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')

  purgeQueue = 'wli.reporting.purge.queue'
  udd=create(purgeQueue,'Queue')
  udd.setJNDIName(purgeQueue)
  udd.setSubDeploymentName('wlsbJMSServer1_sub')
  cd ('Queue')
  cd (purgeQueue)
  #dpo = create('dpoName','DeliveryParamsOverrides')
  #dpo.setRedeliveryDelay(15*60*1000)
  dfp = create('dfpName', 'DeliveryFailureParams')
  dfp.setRedeliveryLimit(2)
  dfp.setExpirationPolicy('Discard')

  cd('/')
  cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')


  osbcf=create('weblogic.wlsb.jms.transporttask.QueueConnectionFactory','ConnectionFactory')
  osbcf.setJNDIName('weblogic.wlsb.jms.transporttask.QueueConnectionFactory')
  cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/ConnectionFactory/weblogic.wlsb.jms.transporttask.QueueConnectionFactory')
  set('DefaultTargetingEnabled', 'true')
  create('TransactionParams', 'TransactionParams')
  cd('TransactionParams/NO_NAME_0')
  cmo.setXAConnectionFactoryEnabled(true)

  cd('/')
  cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')

  osbcf=create('wli.reporting.jmsprovider.ConnectionFactory','ConnectionFactory')
  osbcf.setJNDIName('wli.reporting.jmsprovider.ConnectionFactory')
  cd('/JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0/ConnectionFactory/wli.reporting.jmsprovider.ConnectionFactory')
  set('DefaultTargetingEnabled', 'true')
  create('TransactionParams', 'TransactionParams')
  cd('TransactionParams/NO_NAME_0')
  cmo.setXAConnectionFactoryEnabled(true)

  cd('/')
  cd('JMSSystemResource/jmsResourcesUDDs/JmsResource/NO_NAME_0')

  createJMSServersSB(cluster, 'wsee', 1)

  cd('/')
  create('WseeJmsModuleUDDs','JMSSystemResource')

  cd('/')
  cd('JMSSystemResource/WseeJmsModuleUDDs')
  assign('JMSSystemResource', 'WseeJmsModuleUDDs', 'Target', cluster)

  print ' '
  print ("*** Listing OSB JMS Servers ***")
  s = ls('/JMSServers')
  osbJMSServerStr=''
  serverCnt =  1
  for token in s.split("drw-"):
    token=token.strip().lstrip().rstrip()
    if not token.find("WseeJmsServer_auto") == -1:
      print token
      cd('/')
      cd('JMSSystemResource/WseeJmsModuleUDDs')
      subDeploymentStr = 'WseeJmsServer_auto_'+str(serverCnt)+'-Sub'
      create(subDeploymentStr, 'SubDeployment')

      cd('/')
      cd('JMSSystemResource/WseeJmsModuleUDDs/SubDeployments/'+subDeploymentStr)
      assign('JMSSystemResource.SubDeployment', 'WseeJmsModuleUDDs.'+subDeploymentStr, 'Target', token) 

      cd('/')
      cd('JMSSystemResource/WseeJmsModuleUDDs/JmsResource/NO_NAME_0')

      callBackQueue = 'DefaultCallbackQueue-WseeJmsServer_auto_'+str(serverCnt)
      udd=create(callBackQueue,'Queue')
      udd.setJNDIName('weblogic.wsee.DefaultCallbackQueue-WseeJmsServer_auto_'+str(serverCnt))
      udd.setSubDeploymentName(subDeploymentStr)
      cd ('Queue')
      cd (callBackQueue)
      #dpo = create('dpoName','DeliveryParamsOverrides')
      #dpo.setRedeliveryDelay(15*60*1000)
      dfp = create('dfpName', 'DeliveryFailureParams')
      dfp.setRedeliveryLimit(2)
      dfp.setExpirationPolicy('Discard')

      cd('/')
      cd('JMSSystemResource/WseeJmsModuleUDDs/JmsResource/NO_NAME_0')
      wseeQueue = 'DefaultQueue-WseeJmsServer_auto_'+str(serverCnt)
      udd=create(wseeQueue,'Queue')
      udd.setJNDIName('weblogic.wsee.DefaultQueue-WseeJmsServer_auto_'+str(serverCnt))
      udd.setSubDeploymentName(subDeploymentStr)
      cd ('Queue')
      cd (wseeQueue)
      #dpo = create('dpoName','DeliveryParamsOverrides')
      #dpo.setRedeliveryDelay(15*60*1000)
      dfp = create('dfpName', 'DeliveryFailureParams')
      dfp.setRedeliveryLimit(2)
      dfp.setExpirationPolicy('Discard')

      serverCnt = serverCnt + 1


def createJMSServersBAM12c(cluster, track, currentServerCnt):
  print ' '
  print "Creating JMS Servers for the cluster :- ", cluster
  s = ls('/Server')
  print ' '
  clustername = " "
  serverCnt = currentServerCnt
  for token in s.split("drw-"):
    token=token.strip().lstrip().rstrip()
    path="/Server/"+token
    cd(path)
    if not token == 'AdminServer' and not token == '':
      clustername = get('Cluster')
      print "Cluster Associated with the Server [",token,"] :- ",clustername
      print ' '
      searchClusterStr = cluster+":"
      clusterNameStr = str(clustername)
      print "searchClusterStr = ",searchClusterStr
      print "clusterNameStr = ",clusterNameStr
      if not clusterNameStr.find(searchClusterStr) == -1:
        print token, " is associated with ", cluster
        print ' '
        print "Creating JMS Servers for ", track
        print ' '
        cd('/')

        if track == 'bam':
          jmsServerName = 'BamCQServiceJmsServer_auto_'+str(serverCnt)
          fileStoreName = 'BamCQServiceJmsFileStore_auto_'+str(serverCnt)

        createFileStore(fileStoreName, token)
        print "Created File Store :- ", fileStoreName

        create(jmsServerName, 'JMSServer')
        print "Created JMS Server :- ", jmsServerName
        print ' '
        assign('JMSServer', jmsServerName, 'Target', token)
        print jmsServerName, " assigned to server :- ", token
        print ' '
        cd('/JMSServer/'+jmsServerName)
        set ('PersistentStore', fileStoreName)

        if track == 'wsee':
          safAgent     = 'ReliableWseeSAFAgent_auto_'+str(serverCnt)

          cd('/')
          create(safAgent, 'SAFAgent')
          cd('/SAFAgent/'+safAgent)
          set ('Target'     , token)
          set ('Store'      , fileStoreName)
          set ('ServiceType','Both')

        serverCnt = serverCnt + 1

def BAMJms12c(cluster):

  createJMSServersBAM12c(cluster, 'bam', 1)

  print "create BAM CQ JMSSystemResource"
  cd('/')
  create('BamCQServiceJmsSystemResource','JMSSystemResource')

  print "target BAM CQ JMSSystemResource"
  cd('/')
  cd('JMSSystemResource/BamCQServiceJmsSystemResource')
  assign('JMSSystemResource', 'BamCQServiceJmsSystemResource', 'Target', cluster)

  print "subdeployment BAM CQ JMSSystemResource"
  cd('/')
  cd('JMSSystemResource/BamCQServiceJmsSystemResource')
  create('BamCQServiceAlertEngineSubdeployment', 'SubDeployment')

  cd('/')
  cd('JMSSystemResource/BamCQServiceJmsSystemResource/SubDeployments/BamCQServiceAlertEngineSubdeployment')

  print ' '
  print ("*** Listing Bam CQ JMS Servers ***")
  s = ls('/JMSServers')
  bamJMSServerStr=''
  for token in s.split("drw-"):
    token=token.strip().lstrip().rstrip()
    if not token.find("BamCQServiceJmsServer_auto") == -1:
      bamJMSServerStr = bamJMSServerStr + token +","
    print token

  print ("*** Setting JMS SubModule for BamCQ JMS Server's target***")
  assign('JMSSystemResource.SubDeployment', 'BamCQServiceJmsSystemResource.BamCQServiceAlertEngineSubdeployment', 'Target', bamJMSServerStr)

  cd('/')
  cd('JMSSystemResource/BamCQServiceJmsSystemResource/JmsResource/NO_NAME_0')

  udd=create('BamCQServiceAlertEngineQueue','UniformDistributedQueue')
  udd.setJNDIName('queue/oracle.beam.cqservice.mdbs.alertengine')
  udd.setSubDeploymentName('BamCQServiceAlertEngineSubdeployment')

  udd=create('BamCQServiceReportCacheQueue','UniformDistributedQueue')
  udd.setJNDIName('queue/oracle.beam.cqservice.mdbs.reportcache')
  udd.setSubDeploymentName('BamCQServiceAlertEngineSubdeployment')

  soacf=create('BamCQServiceAlertEngineConnectionFactory','ConnectionFactory')
  soacf.setJNDIName('queuecf/oracle.beam.cqservice.mdbs.alertengine')
  cd('/JMSSystemResource/BamCQServiceJmsSystemResource/JmsResource/NO_NAME_0/ConnectionFactory/BamCQServiceAlertEngineConnectionFactory')
  set('DefaultTargetingEnabled', 'true')
  create('TransactionParams', 'TransactionParams')
  cd('TransactionParams/NO_NAME_0')
  cmo.setXAConnectionFactoryEnabled(true)

  cd('/')
  cd('JMSSystemResource/BamCQServiceJmsSystemResource/JmsResource/NO_NAME_0')

  soacf=create('BamCQServiceReportCacheConnectionFactory','ConnectionFactory')
  soacf.setJNDIName('queuecf/oracle.beam.cqservice.mdbs.reportcache')
  cd('/JMSSystemResource/BamCQServiceJmsSystemResource/JmsResource/NO_NAME_0/ConnectionFactory/BamCQServiceReportCacheConnectionFactory')
  set('DefaultTargetingEnabled', 'true')
  create('TransactionParams', 'TransactionParams')
  cd('TransactionParams/NO_NAME_0')
  cmo.setXAConnectionFactoryEnabled(true)


def createUMSJMSServers(cluster, track, currentServerCnt, adminserver_name):
    print ' '
    print "Creating JMS Servers for the cluster :- ", cluster
    s = ls('/Server')
    print ' '
    clustername = " "
    serverCnt = currentServerCnt
    for token in s.split("drw-"):
        token=token.strip().lstrip().rstrip()
        path="/Server/"+token
        cd(path)
        if not token == adminserver_name and not token == '':
            clustername = get('Cluster')
            print "Cluster Associated with the Server [",token,"] :- ",clustername
            print ' '
            searchClusterStr = cluster+":"
            clusterNameStr = str(clustername)
            print "searchClusterStr = ",searchClusterStr
            print "clusterNameStr = ",clusterNameStr
            if not clusterNameStr.find(searchClusterStr) == -1:
                print token, " is associated with ", cluster
                print ' '
                print "Creating JMS Servers for ", track
                print ' '
                cd('/')

                if track == 'ums':
                    jmsServerName = 'UMSJMSServer_auto_'+str(serverCnt)
                    fileStoreName = 'UMSJMSFileStore_auto_'+str(serverCnt)


                createFileStore(fileStoreName, token)
                print "Created File Store :- ", fileStoreName

                create(jmsServerName, 'JMSServer')
                print "Created JMS Server :- ", jmsServerName
                print ' '
                assign('JMSServer', jmsServerName, 'Target', token)
                print jmsServerName, " assigned to server :- ", token
                print ' '
                cd('/JMSServer/'+jmsServerName)
                set ('PersistentStore', fileStoreName)

                serverCnt = serverCnt + 1

def getCurrentUMSServerCnt():
    s = ls('/JMSServer')
    count = s.count("UMSJMSServer_auto")
    return count + 1

def getUMSJMSServers(cluster, adminserver_name):
    s = ls('/JMSServers')
    jmsServersStr = " "
    print ' '
    clustername = " "
    for token in s.split("drw-"):
        token=token.strip().lstrip().rstrip()
        if not token == '' and not token.find("UMSJMSServer_auto") == -1:
            cd('/JMSServers/'+token)
            targetServer = get('Target')
            clustername = getClusterName(targetServer, adminserver_name)
            searchClusterStr = cluster+":"
            clusterNameStr = str(clustername)
            print "searchClusterStr = ",searchClusterStr
            print "clusterNameStr = ",clusterNameStr
            if not clusterNameStr.find(searchClusterStr) == -1:
                    jmsServersStr = jmsServersStr + token + ","
    print "UMS JMS Servers for Cluster :- ", cluster , " is :- ", jmsServersStr
    return jmsServersStr

def recreateUMSJms12c(adminserver_name, soa_cluster, osb_cluster, bam_cluster, ess_cluster, all_clusters):

    if soa_cluster:
        print "fix SOA UMS JMS"
        createUMSJMSServers(soa_cluster, 'ums', getCurrentUMSServerCnt(), adminserver_name)

    if osb_cluster:
        print "fix BAM UMS JMS"
        createUMSJMSServers(osb_cluster, 'ums', getCurrentUMSServerCnt(), adminserver_name)

    if bam_cluster:
        print "fix OSB UMS JMS"
        createUMSJMSServers(bam_cluster, 'ums', getCurrentUMSServerCnt(), adminserver_name)

    if ess_cluster:
        print "fix ESS UMS JMS"
        createUMSJMSServers(ess_cluster, 'ums', getCurrentUMSServerCnt(), adminserver_name)


    print "create UMSJMSSystemResource"
    cd('/')
    create('UMSJMSSystemResource','JMSSystemResource')

    print "target UMSJMSSystemResource"
    cd('/')
    cd('JMSSystemResource/UMSJMSSystemResource')
    assign('JMSSystemResource', 'UMSJMSSystemResource', 'Target', all_clusters)

    print("*** Creating Connection Factories for UMS ***");
    cd('/')
    cd('JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')

    cf1=create('OraSDPMQueueConnectionFactory','ConnectionFactory')
    cf1.setJNDIName('OraSDPM/QueueConnectionFactory')

    print ("*** Enabling XA ***")
    cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0/ConnectionFactory/OraSDPMQueueConnectionFactory')
    set('DefaultTargetingEnabled', 'true')
    create('TransactionParams', 'TransactionParams')
    cd('TransactionParams/NO_NAME_0')
    cmo.setXAConnectionFactoryEnabled(true)
    cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0/ConnectionFactory/OraSDPMQueueConnectionFactory')
    create('DefaultDeliveryParams', 'DefaultDeliveryParams')
    cd('DefaultDeliveryParams/NO_NAME_0')
    cmo.setDefaultDeliveryMode('Persistent')
    cmo.setDefaultRedeliveryDelay(400)

    cd('/')
    cd('JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
    dk1=create('Priority','DestinationKey')
    dk1.setProperty('JMSPriority')
    dk1.setKeyType('Int')
    dk1.setSortOrder('Descending')

    if soa_cluster:

        print "create subdeployment SOA UMS JMS"
        cd('/')
        cd('JMSSystemResource/UMSJMSSystemResource')
        create('UMSJMSSubDMSOA', 'SubDeployment')

        umsJMSServerStr = getUMSJMSServers(soa_cluster, adminserver_name)
        umsJMSServerStr = umsJMSServerStr.strip().lstrip().rstrip()
        assign('JMSSystemResource.SubDeployment', 'UMSJMSSystemResource.UMSJMSSubDMSOA', 'Target', umsJMSServerStr)

        print ("*** Creating Queues for UMS ***")
        cd('/')
        print ' '

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd= create('OraSDPMEngineSndQ1_soa','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEngineSndQ1')
        udd.setSubDeploymentName('UMSJMSSubDMSOA')
        udd.setDestinationKeys(jarray.array([String('Priority')],String))
        cd ('UniformDistributedQueue/OraSDPMEngineSndQ1_soa')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMEngineRcvQ1_soa','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEngineRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMSOA')
        cd ('UniformDistributedQueue/OraSDPMEngineRcvQ1_soa')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMDriverDefSndQ1_soa','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMDriverDefSndQ1')
        udd.setSubDeploymentName('UMSJMSSubDMSOA')
        udd.setDestinationKeys(jarray.array([String('Priority')],String))
        cd ('UniformDistributedQueue/OraSDPMDriverDefSndQ1_soa')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        uddError=create('OraSDPMAppDefRcvErrorQ1_soa','UniformDistributedQueue')
        uddError.setJNDIName('OraSDPM/Queues/OraSDPMAppDefRcvErrorQ1')
        uddError.setSubDeploymentName('UMSJMSSubDMSOA')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMAppDefRcvQ1_soa','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMAppDefRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMSOA')
        cd ('UniformDistributedQueue/OraSDPMAppDefRcvQ1_soa')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')
        dfp.setErrorDestination(uddError)

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMWSRcvQ1_soa','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMWSRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMSOA')
        cd ('UniformDistributedQueue/OraSDPMWSRcvQ1_soa')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMEnginePendingRcvQ_soa','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEnginePendingRcvQ')
        udd.setSubDeploymentName('UMSJMSSubDMSOA')
        cd ('UniformDistributedQueue/OraSDPMEnginePendingRcvQ_soa')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

    if bam_cluster:
        print "create subdeployment BAM UMS JMS"
        cd('/')
        cd('JMSSystemResource/UMSJMSSystemResource')
        create('UMSJMSSubDMBAM', 'SubDeployment')

        umsJMSServerStr = getUMSJMSServers(bam_cluster, adminserver_name)
        umsJMSServerStr = umsJMSServerStr.strip().lstrip().rstrip()
        assign('JMSSystemResource.SubDeployment', 'UMSJMSSystemResource.UMSJMSSubDMBAM', 'Target', umsJMSServerStr)

        print ("*** Creating Queues for UMS ***")
        cd('/')
        print ' '

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd= create('OraSDPMEngineSndQ1_bam','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEngineSndQ1')
        udd.setSubDeploymentName('UMSJMSSubDMBAM')
        udd.setDestinationKeys(jarray.array([String('Priority')],String))
        cd ('UniformDistributedQueue/OraSDPMEngineSndQ1_bam')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMEngineRcvQ1_bam','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEngineRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMBAM')
        cd ('UniformDistributedQueue/OraSDPMEngineRcvQ1_bam')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMDriverDefSndQ1_bam','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMDriverDefSndQ1')
        udd.setSubDeploymentName('UMSJMSSubDMBAM')
        udd.setDestinationKeys(jarray.array([String('Priority')],String))
        cd ('UniformDistributedQueue/OraSDPMDriverDefSndQ1_bam')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        uddError=create('OraSDPMAppDefRcvErrorQ1_bam','UniformDistributedQueue')
        uddError.setJNDIName('OraSDPM/Queues/OraSDPMAppDefRcvErrorQ1')
        uddError.setSubDeploymentName('UMSJMSSubDMBAM')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMAppDefRcvQ1_bam','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMAppDefRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMBAM')
        cd ('UniformDistributedQueue/OraSDPMAppDefRcvQ1_bam')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')
        dfp.setErrorDestination(uddError)

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMWSRcvQ1_bam','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMWSRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMBAM')
        cd ('UniformDistributedQueue/OraSDPMWSRcvQ1_bam')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMEnginePendingRcvQ_bam','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEnginePendingRcvQ')
        udd.setSubDeploymentName('UMSJMSSubDMBAM')
        cd ('UniformDistributedQueue/OraSDPMEnginePendingRcvQ_bam')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

    if osb_cluster:
        print "create subdeployment OSB UMS JMS"
        cd('/')
        cd('JMSSystemResource/UMSJMSSystemResource')
        create('UMSJMSSubDMOSB', 'SubDeployment')

        umsJMSServerStr = getUMSJMSServers(osb_cluster, adminserver_name)
        umsJMSServerStr = umsJMSServerStr.strip().lstrip().rstrip()
        assign('JMSSystemResource.SubDeployment', 'UMSJMSSystemResource.UMSJMSSubDMOSB', 'Target', umsJMSServerStr)

        print ("*** Creating Queues for UMS ***")
        cd('/')
        print ' '

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd= create('OraSDPMEngineSndQ1_osb','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEngineSndQ1')
        udd.setSubDeploymentName('UMSJMSSubDMOSB')
        udd.setDestinationKeys(jarray.array([String('Priority')],String))
        cd ('UniformDistributedQueue/OraSDPMEngineSndQ1_osb')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMEngineRcvQ1_osb','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEngineRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMOSB')
        cd ('UniformDistributedQueue/OraSDPMEngineRcvQ1_osb')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMDriverDefSndQ1_osb','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMDriverDefSndQ1')
        udd.setSubDeploymentName('UMSJMSSubDMOSB')
        udd.setDestinationKeys(jarray.array([String('Priority')],String))
        cd ('UniformDistributedQueue/OraSDPMDriverDefSndQ1_osb')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        uddError=create('OraSDPMAppDefRcvErrorQ1_osb','UniformDistributedQueue')
        uddError.setJNDIName('OraSDPM/Queues/OraSDPMAppDefRcvErrorQ1')
        uddError.setSubDeploymentName('UMSJMSSubDMOSB')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMAppDefRcvQ1_osb','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMAppDefRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMOSB')
        cd ('UniformDistributedQueue/OraSDPMAppDefRcvQ1_osb')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')
        dfp.setErrorDestination(uddError)

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMWSRcvQ1_osb','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMWSRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMOSB')
        cd ('UniformDistributedQueue/OraSDPMWSRcvQ1_osb')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMEnginePendingRcvQ_osb','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEnginePendingRcvQ')
        udd.setSubDeploymentName('UMSJMSSubDMOSB')
        cd ('UniformDistributedQueue/OraSDPMEnginePendingRcvQ_osb')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

    if ess_cluster:
        print "create subdeployment ESS UMS JMS"
        cd('/')
        cd('JMSSystemResource/UMSJMSSystemResource')
        create('UMSJMSSubDMESS', 'SubDeployment')

        umsJMSServerStr = getUMSJMSServers(ess_cluster, adminserver_name)
        umsJMSServerStr = umsJMSServerStr.strip().lstrip().rstrip()
        assign('JMSSystemResource.SubDeployment', 'UMSJMSSystemResource.UMSJMSSubDMESS', 'Target', umsJMSServerStr)

        print ("*** Creating Queues for UMS ***")
        cd('/')
        print ' '

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd= create('OraSDPMEngineSndQ1_ess','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEngineSndQ1')
        udd.setSubDeploymentName('UMSJMSSubDMESS')
        udd.setDestinationKeys(jarray.array([String('Priority')],String))
        cd ('UniformDistributedQueue/OraSDPMEngineSndQ1_ess')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMEngineRcvQ1_ess','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEngineRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMESS')
        cd ('UniformDistributedQueue/OraSDPMEngineRcvQ1_ess')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMDriverDefSndQ1_ess','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMDriverDefSndQ1')
        udd.setSubDeploymentName('UMSJMSSubDMESS')
        udd.setDestinationKeys(jarray.array([String('Priority')],String))
        cd ('UniformDistributedQueue/OraSDPMDriverDefSndQ1_ess')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        uddError=create('OraSDPMAppDefRcvErrorQ1_ess','UniformDistributedQueue')
        uddError.setJNDIName('OraSDPM/Queues/OraSDPMAppDefRcvErrorQ1')
        uddError.setSubDeploymentName('UMSJMSSubDMESS')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMAppDefRcvQ1_ess','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMAppDefRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMESS')
        cd ('UniformDistributedQueue/OraSDPMAppDefRcvQ1_ess')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')
        dfp.setErrorDestination(uddError)

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMWSRcvQ1_ess','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMWSRcvQ1')
        udd.setSubDeploymentName('UMSJMSSubDMESS')
        cd ('UniformDistributedQueue/OraSDPMWSRcvQ1_ess')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')

        cd('/JMSSystemResource/UMSJMSSystemResource/JmsResource/NO_NAME_0')
        udd=create('OraSDPMEnginePendingRcvQ_ess','UniformDistributedQueue')
        udd.setJNDIName('OraSDPM/Queues/OraSDPMEnginePendingRcvQ')
        udd.setSubDeploymentName('UMSJMSSubDMESS')
        cd ('UniformDistributedQueue/OraSDPMEnginePendingRcvQ_ess')
        dfp = create('dfpName', 'DeliveryFailureParams')
        dfp.setRedeliveryLimit(2)
        dfp.setExpirationPolicy('Log')


def sb12c(cluster):
  createJMSServersSB(cluster, 'wsee', 1)

  cd('/')
  create('WseeJmsModule','JMSSystemResource')

  cd('/')
  cd('JMSSystemResource/WseeJmsModule')
  assign('JMSSystemResource', 'WseeJmsModule', 'Target', cluster)

  print ' '
  print ("*** Listing OSB JMS Servers ***")
  s = ls('/JMSServers')
  osbJMSServerStr=''
  serverCnt =  1
  for token in s.split("drw-"):
    token=token.strip().lstrip().rstrip()
    if not token.find("WseeJmsServer_auto") == -1:
      print token
      cd('/')
      cd('JMSSystemResource/WseeJmsModule')
      subDeploymentStr = 'WseeJmsServer_auto_'+str(serverCnt)+'-Sub'
      create(subDeploymentStr, 'SubDeployment')

      cd('/')
      cd('JMSSystemResource/WseeJmsModule/SubDeployments/'+subDeploymentStr)
      assign('JMSSystemResource.SubDeployment', 'WseeJmsModule.'+subDeploymentStr, 'Target', token) 

      cd('/')
      cd('JMSSystemResource/WseeJmsModule/JmsResource/NO_NAME_0')

      callBackQueue = 'DefaultCallbackQueue-WseeJmsServer_auto_'+str(serverCnt)
      udd=create(callBackQueue,'Queue')
      udd.setJNDIName('weblogic.wsee.DefaultCallbackQueue-WseeJmsServer_auto_'+str(serverCnt))
      udd.setLocalJNDIName('weblogic.wsee.DefaultCallbackQueue')
      udd.setSubDeploymentName(subDeploymentStr)

      cd('/')
      cd('JMSSystemResource/WseeJmsModule/JmsResource/NO_NAME_0')
      wseeQueue = 'DefaultQueue-WseeJmsServer_auto_'+str(serverCnt)
      udd=create(wseeQueue,'Queue')
      udd.setJNDIName('weblogic.wsee.DefaultQueue-WseeJmsServer_auto_'+str(serverCnt))
      udd.setLocalJNDIName('weblogic.wsee.DefaultQueue')
      udd.setSubDeploymentName(subDeploymentStr)

      serverCnt = serverCnt + 1
