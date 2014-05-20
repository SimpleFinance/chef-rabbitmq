# libraries/management.rb
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
# Administrative management helpers for a RabbitMQ node

module RabbitMQ
  module Management
    @@client = nil

    def rabbitmq_client
      if @@client
        return @@client
      else
        require 'rabbitmq/http/client'
        @@client = RabbitMQ::HTTP::Client.new(
          "http://#{opts[:host]}:#{opts[:port]}",
          username: opts[:username],
          password: opts[:password],
          ssl: opts[:ssl]
        )
        return @@client
      end
    end

    # A small handle to give us either node[:rabbitmq][:admin_user] or 'guest',
    # one of the two being the user to hit the API with.
    def rabbitmq_admin_user
      return opts[:username]
    end

    private

    def opts
      return {
        host: node.fetch(:rabbitmq, {})['admin_host'] || '127.0.0.1',
        port: node.fetch(:rabbitmq, {})['admin_port'] || 15672,
        username: node.fetch(:rabbitmq, {})['admin_user'] || 'guest',
        password: node.fetch(:rabbitmq, {})['admin_pass'] || 'guest',
        ssl: node.fetch(:rabbitmq, {})['admin_ssl_opts'] || {}
      }
    end
  end
end
