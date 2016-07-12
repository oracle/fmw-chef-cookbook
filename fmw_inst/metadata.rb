name             'fmw_inst'
maintainer       'Oracle'
maintainer_email 'fmw-chef-and-puppet_ww@oracle.com'
license          'MIT'
description      'Installs FMW Software on a WebLogic middleware environmment'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.2'

recipe            "fmw_inst",
                  "This is an empty recipe and does not do anything"
recipe            "fmw_inst::jrf",
                  "This will install 11g ADF/JRF on a Middleware home"
recipe            "fmw_inst::mft",
                  "This will install MFT (Managed File Transfer) on a Middleware home"
recipe            "fmw_inst::service_bus",
                  "This will install the Service Bus on a Middleware home"
recipe            "fmw_inst::soa_suite",
                  "This will install the SOA Suite on a Middleware home"
recipe            "fmw_inst::webcenter",
                  "This will install the Webcenter on a Middleware home"
recipe            "fmw_inst::oim",
                  "This will install the Oracle Identity/Accesss Manager on a Middleware home"

depends          'fmw_wls'

%w{ windows solaris debian ubuntu redhat centos oracle sles }.each do |os|
  supports os
end
