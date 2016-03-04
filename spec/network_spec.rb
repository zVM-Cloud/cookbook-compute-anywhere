# encoding: UTF-8
#
# Cookbook Name:: openstack-zvm-compute-anywhere
# Recipe:: network-cma
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

require_relative 'spec_helper'

describe 'openstack-zvm-compute-anywhere::network-cma' do
  include_context 'network-common-stubs'
  describe 'redhat' do
    let(:runner) { ChefSpec::ServerRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      node.set['openstack']['compute']['network']['service_type'] = 'neutron'
      node.set['openstack']['network']['rpc_thread_pool_size'] = 1000
      runner.converge(described_recipe)
    end

    it 'check neutron conf' do
      expect(chef_run).to create_template('/etc/neutron/neutron.conf').with(
        owner: 'neutron',
        group: 'neutron',
        mode: 00640
      )

      expect(chef_run).to render_file('/etc/neutron/neutron.conf').with_content('rpc_thread_pool_size = 1000')
      expect(chef_run).to render_file('/etc/neutron/neutron.conf').with_content('admin_password = neutron-pass')
    end

    it 'starts neutron-zvm-agent' do
      expect(chef_run).to start_service('neutron-zvm-agent')
    end
  end
end
