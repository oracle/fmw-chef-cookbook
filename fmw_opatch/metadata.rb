name             'fmw_opatch'
maintainer       'Oracle'
maintainer_email 'fmw-chef-and-puppet_ww@oracle.com'
license          'MIT'
description      'Patch Oracle WebLogic 12c or any FMW 11g or 12c product'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.5'

recipe            "fmw_opatch",
                  "This is an empty recipe and does not do anything"
recipe            "fmw_opatch::weblogic",
                  "This will apply the WebLogic patch on a Middleware home"
recipe            "fmw_opatch::service_bus",
                  "This will apply the Service Bus patch on an Oracle Service Bus home"
recipe            "fmw_opatch::soa_suite",
                  "This will apply the SOA Suite patch on an Oracle SOA Suite home"

depends          'fmw_wls'
depends          'fmw_inst'

%w{ windows solaris debian ubuntu redhat centos oracle sles }.each do |os|
  supports os
end

