name             'openstack-zvm-compute-anywhere'
maintainer       'IBM Corp.'
maintainer_email 'https://github.com/zVM-Cloud'
license          'Apache 2.0'
description      'Installs/Configures openstack-zvm-compute-anywhere'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '12.0.2'

recipe 'openstack-zvm-compute-anywhere::compute-cma', 'Reconfigures nova on CMA to make it work with external controller'
recipe 'openstack-zvm-compute-anywhere::network-cma', 'Reconfigures neutron on CMA to make it work with external controller'
recipe 'openstack-zvm-compute-anywhere::ceilometer-cma', 'Reconfigures ceilometer on CMA to make it work with external controller'

supports 'redhat'

depends 'openstack-common', '>= 12.0.0'
depends 'openstack-compute', '>= 12.0.0'
depends 'openstack-network', '>= 12.0.0'
depends 'openstack-telemetry', '>= 12.0.0'
