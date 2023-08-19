import Config

# NOTE: honeycomb dataset is determined from the api key, not the header
config :opentelemetry_exporter,
  otlp_protocol: :http_protobuf,
  otlp_compression: :gzip,
  otlp_endpoint: "https://api.honeycomb.io:443",
  otlp_headers: [
    {"x-honeycomb-team", System.get_env("HONEYCOMB_KEY")}
  ]
