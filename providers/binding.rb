# providers/binding.rb
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
# Declare and delete bindings from exchanges to queues.

include RabbitMQ::Management

def initialize(new_resource, run_context)
  super
  @client      = rabbitmq_client
  @vhost       = new_resource.vhost
  @exchange    = new_resource.exchange
  @queue       = new_resource.queue
  @binding     = new_resource.binding
  @routing_key = new_resource.routing_key
  @props_key   = new_resource.props_key
end

action :declare do
  # See http://www.rabbitmq.com/access-control.html for a more in-depth
  # explanation of these permissions. Full access is required to bind a queue
  # to an exchange.
  @client.update_permissions_of(
    @vhost,
    rabbitmq_admin_user,
    read: '.*',
    write: '.*',
    configure: '.*'
  )
  @client.bind_queue(@vhost, @queue, @exchange, @routing_key)
  @client.update_permissions_of(
    @vhost,
    rabbitmq_admin_user,
    read: '',
    write: '',
    configure: '.*'
  )
end

action :delete do
  @client.delete_queue_binding(@vhost, @queue, @exchange, @props_key)
end
