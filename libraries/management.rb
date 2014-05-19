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
  class Manager
    attr_accessor(:opts, :client)

    def initialize(opts={})
      @opts   = opts
      @client = create_client
    end

    def admin
      return @opts[:username]
    end

    def create_client
      require 'rabbitmq/http/client'

      @opts.merge!(defaults)
      return RabbitMQ::HTTP::Client.new(
        "http://#{@opts[:host]}:#{@opts[:port]}",
        username: @opts[:username],
        password: @opts[:password],
        ssl: @opts[:ssl]
      )
    end

    private

    def defaults(data={})
      return {
        host: data.fetch('admin_host', '127.0.0.1'),
        port: data.fetch('admin_port', 15672),
        username: data.fetch('admin_user', 'guest'),
        password: data.fetch('admin_pass', 'guest'),
        ssl: data.fetch('admin_ssl_opts', {})
      }
    end
  end
end
