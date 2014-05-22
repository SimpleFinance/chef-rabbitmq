# providers/user.rb
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
# Create, delete, and modify RabbitMQ users

include RabbitMQ::Management

def initialize(new_resource, run_context)
  super
  @client      = rabbitmq_client
  @user        = new_resource.user
  @tags        = new_resource.tags
  @password    = new_resource.password
  @vhost       = new_resource.vhost
  @permissions = new_resource.permissions
end

# Adds and/or modifies a user for RabbitMQ, including permissions on a
# virtualhost, password, and tags.
action :add do
  add_or_update_user
end

# Adds and/or modifies a user for RabbitMQ, including permissions on a
# virtualhost, password, and tags.
action :update do
  add_or_update_user
end

# Erases the user's permissions on the given virtualhost
action :clear_permissions do
  @client.clear_permissions_of(@user, @vhost)
end

# Deletes the user from RabbitMQ
action :delete do
  @client.delete_user(@user)
end

private

def add_or_update_user
  @client.update_user(@user, compile_attributes)
  if @permissions && @vhost
    Chef::Log.info("Updating #{@user} permissions to #{@permissions} on #{@vhost}")
    read, write, conf = @permissions.split(" ")
    @client.update_permissions_of(
      @vhost, 
      @user, 
      read: read, 
      write: write, 
      configure: conf
    )
  end
end

def compile_attributes
  return {
    password: @password,
    tags: @tags
  }
end
