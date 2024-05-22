# Satellite

**Satellite helps you to easily start a pool of Consumers and Producers in your application**

### The following consumers are supported

- [ ] Redis Pubsub
- [ ] Amazon SQS
- [ ] RabbitMQ

### The following producers are supported

- [x] Redis 
- [x] Amazon SQS
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

## Add configs

```elixir
config :satellite,
  enabled: true,
  origin: "my_app",
  producer: {Satellite.RedisProducer, %{host: "127.0.0.1", port: 6379}}
```
more configs will be added soon..

## Add Satellite to your application

```elixir

  @impl true
  def start(_type, _args) do
    children = [
      # Starts Satellite
      {Satellite, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supporte
    d options
    opts = [strategy: :one_for_one, name: Antenna.Supervisor]
    Supervisor.start_link(children, opts)
  end
```