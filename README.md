# Satellite

**Satellite helps you to easily start a pool of Event Sources and Sinks in your application**

### The following sources are supported

- [x] Redis Pubsub
- [ ] Amazon SQS
- [ ] RabbitMQ

### The following sinks are supported

- [x] Redis 
- [x] Amazon SQS
- [x] Kinesis
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
  producer: {Satellite.RedisProducer, %{host: "127.0.0.1", port: 6379}},
  consumer: 
    {Satellite.RedisConsumer,
      connection: [
        host: "127.0.0.1",
        port: 6379
      ],
      channels: ["robot:*" ,"user:*"]
    },
  batchers: [
    concurrency: 2,
    batch_size: 10,
    batch_timeout: 5000
  ],
  processors_concurrency: 1,
  services: []
```

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
