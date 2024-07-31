import Config

config :satellite,
  origin: "satellite",
  handler:
    {Satellite.Handler.Redis,
     connection: [
       host: "127.0.0.1",
       port: 6379
     ],
     name: :test_name},
  bridge: %{
    services: [IdentityProcessor],
    sink:
      {Satellite.Bridge.Sink.Kinesis,
       kinesis_role_arn: 1, kinesis_stream_name: "foo_stream", assume_role_region: "eu-west-1"},
    source:
      {Satellite.Bridge.Source.Redis,
       connection: [host: "127.0.0.1", port: 6379], channels: ["robot:*", "user:*"]},
    processors_concurrency: 2,
    batchers: [
      concurrency: 2,
      batch_size: 1,
      batch_timeout: 5000
    ]
  }
