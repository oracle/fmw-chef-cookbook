# Oracle WebLogic CHEF cookbooks

## Chef support
- Version 12, 13 ( use v0.1.3 release for chef 11 support)
- Chef solo, client/server
- Databags (encrypted)

## WebLogic Chef 12 & 13 Support for
- The installation & configuration of the JDK, WebLogic and Fusion Middleware (FMW) software
- WebLogic & FMW patching
- WebLogic version 10.3.6, 11.1, 12.1 & 12.2
- Windows, Linux ( RedHat / Debian family ) & Solaris
- Creation of a Domain ( in development mode)
	- Optional with Clusters
	- Extend the domain with ADF/JRF, SOA Suite, Service Bus, Webtier etc

## Restrictions
- Will not download of all the required JDK, WebLogic or FMW software from OTN. They should be available on the host (local or from a share)
- Does not download patches from https://support.oracle.com
- Does not give you the right to use all the FMW software
- Check your license or make sure you comply with the OTN developer license agreement
- You cannot ask Oracle support for help but
	- You can ask the community for help
    - Look at the source code
    - Raise an issue on the right Oracle github repository or send a pull request.

## Our Chef Guidelines
- Provide Chef Resources & Providers
- Provide example Chef recipes to give you a jumpstart
- Which should be minimal
- Should be easy to create your own recipes
- Model driven
- should detect changes
- Use all the available test frameworks to test our code like
    - rspec
    - foodcritic
    - rubocop
    - test kitchen

## Chef cookbooks overview
- fmw_jdk, installation of the Java Development Kit.
- fmw_wls, installation of WebLogic
- fmw_inst, installation of Fusion Middleware software
- fmw_bsu, patch WebLogic 10.3.6/ 11g / 12.1.1
- fmw_opatch, patch Weblogic 12c and FMW 11g & 12c
- fmw_rcu, create a FMW repository on am Oracle Database
- fmw_domain, create a WebLogic Domain and optional extend this domain

### fmw_jdk
- Installs JDK 7 or 8
- Optional configures the RNG/Urandom service on Linux enviroments to fix the lack of entropy when creating or starting WebLogic domains
- For Windows it requires the exe file as source
- For Linux you can use the tar.gz as source or in case of RedHat Family distributions you can also use RPM as source
- For Solaris you can use tar.gz or tar.Z

### fmw_wls
- installs WebLogic 10.3.6/11g & all 12c versions
- Normal WebLogic or the Infrastructure edition
- Optional create on Solaris or Linux an Oracle user and group

### fmw_inst
- install FMW 11g/ 12c software
	- JRF/ADF 11g
	- SOA Suite & Service Bus 11g, 12.1.3, 12.2.1
	- MFT 12.1.3, 12.2.1
	- OIM 11.2
	- WebCenter 11g

### fmw_bsu
- patch WebLogic 10.3.6/11g and 12.1.1

### fmw_opatch
- patch WebLogic 12c and FMW 11g, 12c

### fmw_rcu
- create a 11g or 12c FMW repository on an Oracle Database
	- Common with WLS, OPSS database schemas
	- SOA Suite with WLS, OPSS, SOA, BAM, ESS

### fmw_domain
- Create a domain in development mode
- Configure the NodeManager service
- Start the AdminServer
- Extend the domain with
	- ADF/JRF
	- Service Bus
 	- SOA Suite optional with BPM, BAM and Enterprise Scheduler
 	- Webtier

## Examples

Chef FMW sample configurations can be found here on this [OTN page](http://www.oracle.com/technetwork/indexes/samplecode/chef-puppet-samples-2952079.html)

## Changes

See [CHANGELOG](https://github.com/oracle/chef-samples/tree/master/CHANGELOG.md)

## Contributing

chef-samples is an open source project. See
[CONTRIBUTING](https://github.com/oracle/chef-samples/tree/master/CONTRIBUTING.md)
for details.

Oracle gratefully acknowledges the contributions to chef-samples that have been made by the community.

## License

"The MIT License (MIT)

Copyright (c) 2016, Oracle and/or its affiliates.  All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE."