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
    DEFAULTS = {
      'admin_host' => '127.0.0.1',
      'admin_port' => 15672,
      'admin_user' => 'guest',
      'admin_pass' => 'guest',
      'admin_ssl_opts' => {}
    }

    def rabbitmq_client
      require 'rabbitmq/http/client'
      opts = DEFAULTS.merge(node.fetch(:rabbitmq, {}))
      return RabbitMQ::HTTP::Client.new(
        "http://#{opts['admin_host']}:#{opts['admin_port']}",
        username: opts['admin_user'],
        password: opts['admin_pass'],
        ssl: opts['admin_ssl_opts']
      )
    end

    # A small handle to give us either node[:rabbitmq][:admin_user] or 'guest',
    # one of the two being the user to hit the API with.
    def rabbitmq_admin_user
      return node.fetch(:rabbitmq, {})['admin_user'] || DEFAULTS['admin_user']
    end
  end
end
