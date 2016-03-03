# encoding: UTF-8
#
# Cookbook Name:: ibm_openstack_compute_anywhere
# Recipe:: network-cma
#
# =================================================================
# Licensed Materials - Property of IBM
#
# (c) Copyright IBM Corp. 2015, 2016 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
# =================================================================

require_relative 'spec_helper'

describe 'ibm-openstack-compute-anywhere::network-cma' do
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
