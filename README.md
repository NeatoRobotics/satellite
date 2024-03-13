# Satellite

**Satellite helps you to easily start a pool of Consumers and Producers in your application**

### The following consumers are supported

- [ ] Redis Pubsub
- [ ] Amazon SQS
- [ ] RabbitMQ

### The following producers are supported

- [x] Redis 
- [ ] Amazon SQS
- [ ] RabbitMQ

more details will be added soon...

## Installation

Add the `:satellite` dependency to your `mix.exs` file. If you plan on connecting to a Redis server over SSL you may want to add the optional `:castore` dependency as well:


```elixir
def deps do
  [
    {:satellite, "~> 0.1.0"},
    {:castore, ">= 0.0.0"}
  ]
end
```