name             'fmw_domain'
maintainer       'Oracle'
maintainer_email 'fmw-chef-and-puppet_ww@oracle.com'
license          'MIT'
description      'Create a WebLogic (FMW) Domain with FMW extensions on a Windows, Linux or Solaris host'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.1'

recipe            "fmw_domain",
                  "This is an empty recipe and does not do anything"
recipe            "fmw_domain::domain",
                  "This will create a basic WebLogic domain"
recipe            "fmw_domain::nodemanager",
                  "Configures the nodemanager, create and starts the nodemanager service"
recipe            "fmw_domain::adminserver",
                  "Starts the AdminServer WebLogic instance by connecting to the nodemanager"
recipe            "fmw_domain::extension_jrf",
                  "Extend the standard domain with JRF/ADF"
recipe            "fmw_domain::extension_service_bus",
                  "Extend the standard domain with Oracle Service Bus"
recipe            "fmw_domain::extension_soa_suite",
                  "Extend the standard domain with Oracle SOA Suite"
recipe            "fmw_domain::extension_bam",
                  "Extend the standard domain with BAM of Oracle SOA Suite"
recipe            "fmw_domain::extension_enterprise_scheduler",
                  "Extend the standard domain with Enterprise Schuduler (ESS) of Oracle SOA Suite 12c"
recipe            "fmw_domain::extension_webtier",
                  "Extend the standard domain with Webtier for OHS 12c"

depends          'fmw_wls'
depends          'fmw_inst'

%w{ windows solaris debian ubuntu redhat centos oracle sles }.each do |os|
  supports os
end

