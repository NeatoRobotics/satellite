import Config

config :satellite,
  origin: "foo",
  handler:
    {Satellite.Handler.Redis,
     connection: [
       host: "127.0.0.1",
       port: 6379
     ],
     name: :test_name},
  bridge: %{
    services: [],
    sink:
      {Satellite.Bridge.Sink.Kinesis,
       kinesis_role_arn: 1, kinesis_stream_name: "foo_stream", assume_role_region: "eu-west-1"},
    source:
      {Satellite.Bridge.Source.Redis,
       connection: [host: "127.0.0.1", port: 6379], channels: ["robot:*", "user:*"]},
    processors_concurrency: 1,
    batchers: [
      concurrency: 1,
      batch_size: 1,
      batch_timeout: 5000
    ]
  },
  producer_module: Broadway.DummyProducer,
  producer_options: []
