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
    @@admin = 'guest'

    def rabbitmq_admin
      @@admin
    end

    def new_management_object(opts={})
      require 'rabbitmq/http/client'

      opts = defaults.merge!(opts)
      @@admin = opts[:username]
      return RabbitMQ::HTTP::Client.new(
        "http://#{opts[:host]}:#{opts[:port]}",
        username: opts[:username],
        password: opts[:password],
        ssl: opts[:ssl]
      )
    end

    private

    def defaults
      return {
        host: '127.0.0.1',
        port: 15672,
        username: 'guest',
        password: 'guest',
        ssl: {}
      }
    end
  end
end
