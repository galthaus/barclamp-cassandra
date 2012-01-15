# Copyright 2011, Dell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class CassandraService < ServiceObject

  def initialize(thelogger)
    @bc_name = "cassandra"
    @logger = thelogger
  end

  def self.allow_multiple_proposals?
    true
  end

  def proposal_dependencies(role)
    answer = []
    # answer << { "barclamp" => "mysql", "inst" => role.default_attributes["cassandra"]["db"]["mysql_instance"] }
    answer
  end

  #
  # GREG: Must deal with ring id
  #
  # Lots of enhancements here.  Like:
  #    * Don't reuse machines
  #    * validate hardware.
  #
  def create_proposal
    @logger.debug("Cassandra create_proposal: entering")
    base = super
    @logger.debug("Cassandra create_proposal: done with base")

    nodes = NodeObject.all
    nodes.delete_if { |n| n.nil? or n.admin? }
    head = nodes.shift
    nodes = [ head ] if nodes.empty?
    base["deployment"]["cassandra"]["elements"] = {
      "cassandra-server" => nodes.map { |x| x.name }
    }

    @logger.debug("Cassandra create_proposal: exiting")
    base
  end

  def apply_role_pre_chef_call(old_role, role, all_nodes)
    @logger.debug("Cassandra apply_role_pre_chef_call: entering #{all_nodes.inspect}")
    return if all_nodes.empty?

    # Handle addressing
    #
    # Make sure that the front-end pieces have public ip addreses.
    #   - if we are in HA mode, then that is all nodes.
    #
    net_svc = NetworkService.new @logger

    tnodes = role.override_attributes["cassandra"]["elements"]["cassandra-server"]
    unless tnodes.nil? or tnodes.empty?
      tnodes.each do |n|
        net_svc.allocate_ip "default", "public", "host", n
      end
    end

    @logger.debug("Cassandra apply_role_pre_chef_call: leaving")
  end

end

