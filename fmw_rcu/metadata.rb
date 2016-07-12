name             'fmw_rcu'
maintainer       'Oracle'
maintainer_email 'fmw-chef-and-puppet_ww@oracle.com'
license          'MIT'
description      'Installs Oracle WebLogic 11g,12c on any Windows, Linux or Solaris host'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'

recipe            "fmw_rcu",
                  "This is an empty recipe and does not do anything"
recipe            "fmw_rcu::common",
                  "This will create a basic FMW repository with OPSS, UMS etc on an Oracle Database"
recipe            "fmw_rcu::soa_suite",
                  "This will create a FMW SOA Suite repository on an Oracle Database"

depends          'fmw_inst'
depends          'fmw_wls'

%w{ windows debian ubuntu redhat centos oracle sles }.each do |os|
  supports os
end
