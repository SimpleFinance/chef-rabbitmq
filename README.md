## RabbitMQ
A Chef cookbook for managing, installing, and configuring RabbitMQ, an Erlang
message queue application. This cookbook is powered in particular by the
[rabbitmq\_http\_api\_client
gem](https://github.com/ruby-amqp/rabbitmq_http_api_client) and the [amqp
gem](https://github.com/ruby-amqp/amqp). As such, it forces the management API
to be available, and can accomplish anything from queue management to user
creation and deletion.

### Usage
This cookbook attempts to maintain some backwards-compatibility with the
[Opscode RabbitMQ cookbook](https://github.com/opscode-cookbooks/rabbitmq), but
has some changes that will require attention in the event of a migration.

### Resources

#### rabbitmq

#### rabbitmq\_user

#### rabbitmq\_vhost

#### rabbitmq\_exchange

#### rabbitmq\_queue

### TODO
* Runit support

## Author and License
Simple Finance \<ops@simple.com\>

Apache License, Version 2.0

