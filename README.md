**Table of Contents**

- [RabbitMQ](#rabbitmq)
	- [Usage](#usage)
	- [Resources](#resources)
		- [rabbitmq](#rabbitmq)
		- [rabbitmq\_user](#rabbitmq\_user)
		- [rabbitmq\_vhost](#rabbitmq\_vhost)
		- [rabbitmq\_exchange](#rabbitmq\_exchange)
		- [rabbitmq\_queue](#rabbitmq\_queue)
	- [TODO](#todo)
- [Author and License](#author-and-license)

## RabbitMQ
A Chef cookbook for managing, installing, and configuring RabbitMQ, an Erlang
message queue application. This cookbook is powered in particular by the
[rabbitmq\_http\_api\_client
gem](https://github.com/ruby-amqp/rabbitmq_http_api_client) and the [amqp
gem](https://github.com/ruby-amqp/amqp). As such, it forces the management API
to be available, and can accomplish anything from queue management to user
creation and deletion.

It also provides helpers to make RabbitMQ config rendering nice and trivial
(yay!).

### Usage
This cookbook attempts to maintain some backwards-compatibility with the
[Opscode RabbitMQ cookbook](https://github.com/opscode-cookbooks/rabbitmq), but
has some changes that will require attention in the event of a migration.

### Resources

#### rabbitmq
Installs RabbitMQ with the management plugin.

Example : 
``` ruby
rabbitmq 'application' do
  action :install
end
```

#### rabbitmq\_user
This resource manages users in RabbitMQ.

Example : 
``` ruby
rabbitmq_user 'waffle' do
  action :add
end
```

#### rabbitmq\_vhost
This resource manages virtualhosts.

Example : 
``` ruby
rabbitmq_vhost '/vhost' do
  action :add
end
```

#### rabbitmq\_exchange
TODO

#### rabbitmq\_queue
TODO

### TODO
* Runit support
* Policies
* Plugins
* Exchanges
* Queues

## Author and License
Simple Finance \<ops@simple.com\>

Apache License, Version 2.0

