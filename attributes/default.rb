# encoding: UTF-8
#
# Copyright 2015, 2016 IBM Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Set to some text value if you want templated config files
# to contain a custom banner at the top of the written file
default['ibm-openstack']['zvm-driver']['custom_template_banner'] = '
# This file autogenerated by Chef
# Do not edit, changes will be overwritten
'

# nova configuration for optimization
# The memory overcommit ratio for the z/VM Driver. The recommended value is 3.
default['ibm-openstack']['zvm-driver']['config']['ram_allocation_ratio'] = 3
# Live migration will not succeed with the default value, so set it to 180 seconds.
default['ibm-openstack']['zvm-driver']['rpc_response_timeout'] = 180

# ceilometer configuration for optimization
# Interval of ceilometer cached data update.
default['ibm-openstack']['zvm-driver']['cache_update_interval'] = 600
