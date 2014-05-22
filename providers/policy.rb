# providers/policy.rb
#
# Author: Simple Finance <ops@simple.com>
# License: Apache License, Version 2.0
#
# Copyright 2013 Simple Finance Technology Corporation
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
# Manage policies on RabbitMQ virtualhosts

include RabbitMQ::Management

def initialize(new_resource, run_context)
  super
  @client       = rabbitmq_client
  @name         = new_resource.name
  @vhost        = new_resource.vhost
  @definition   = new_resource.definition
  @pattern      = new_resource.pattern
  @priority     = new_resource.priority
  @apply_to     = new_resource.apply_to
end

action :set do
  if !apply_to_valid?
    Chef::Log.error("Parameter `apply_to` must be one of 'all', 'queues', or 'exchanges'!")
    return
  end
  attrs = compile_attributes
  @client.update_policies_of(@vhost, @name, attrs)
end

action :clear do
  @client.clear_policies_of(@vhost, @name)
end

private

def compile_attributes
  return {
    'pattern' => @pattern,
    'definition' => @definition,
    'priority' => @priority,
    'apply-to' => @apply_to
  }
end

# The `apply-to` parameter can only be a couple things to be valid.
def apply_to_valid?
  return ['all', 'exchanges', 'queues'].include?(@apply_to)
end
