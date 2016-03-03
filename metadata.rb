name             'ibm-openstack-compute-anywhere'
maintainer       'IBM Corp.'
maintainer_email 'www.ibm.com'
license          'All rights reserved'
description      'Installs/Configures ibm-openstack-compute-anywhere'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '12.0.2'

recipe 'ibm-openstack-compute-anywhere::compute-cma', 'Reconfigures nova on CMA to make it work with external controller'
recipe 'ibm-openstack-compute-anywhere::network-cma', 'Reconfigures neutron on CMA to make it work with external controller'
recipe 'ibm-openstack-compute-anywhere::ceilometer-cma', 'Reconfigures ceilometer on CMA to make it work with external controller'

supports 'redhat'

depends 'openstack-common', '>= 12.0.0'
depends 'openstack-compute', '>= 12.0.0'
depends 'openstack-network', '>= 12.0.0'
depends 'openstack-telemetry', '>= 12.0.0'
