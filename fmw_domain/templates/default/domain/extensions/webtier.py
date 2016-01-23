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
ADMIN_SERVER_NAME = '<%= @adminserver_name %>'

# templates
WLS_EM_TEMPLATE      = '<%= @wls_em_template %>'
WLS_WEBTIER_TEMPLATE = '<%= @wls_webtier_template %>'

RESTRICTED          = '<%= @restricted %>'

# repository
REPOS_DBURL         = '<%= @repository_database_url %>'
REPOS_DBUSER_PREFIX = '<%= @repository_prefix %>'
REPOS_DBPASSWORD    = sys.argv[2]

readDomain(DOMAIN_PATH)

cd('/')
setOption( "AppDir", APP_PATH )

print 'Adding EM Template'
addTemplate(WLS_EM_TEMPLATE)
dumpStack()

print 'Adding OHS Template'
addTemplate(WLS_WEBTIER_TEMPLATE)
dumpStack()

if RESTRICTED == 'false':
    print 'Change datasource LocalScvTblDataSource for service table'
    changeDatasource('LocalSvcTblDataSource', REPOS_DBUSER_PREFIX+'_STB', REPOS_DBPASSWORD, REPOS_DBURL)
    print 'Call getDatabaseDefaults which reads the service table'
    getDatabaseDefaults()
    print 'end datasources'

print 'Add server group JRF-MAN-SVR to AdminServer'
serverGroup = ["JRF-MAN-SVR"]
setServerGroups(ADMIN_SERVER_NAME, serverGroup)
print 'end server groups'

updateDomain()
dumpStack()

closeDomain()

print('Exiting...')
exit()
