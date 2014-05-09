# resources/binding.rb
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
# Declare, manage, and delete RabbitMQ bindings.

actions(:declare, :delete)
default_action(:declare)

attribute(:binding,     kind_of: String, name_attribute: true)
attribute(:exchange,    kind_of: String, required: true)
attribute(:vhost,       kind_of: String, required: true)
attribute(:queue,       kind_of: String, required: true)
attribute(:routing_key, kind_of: String, default: '')
attribute(:props_key,   kind_of: String)
