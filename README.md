# ExFactory

Automatic redeployment system for `docker-compose`.

[Hex docs](https://hexdocs.pm/ex_factory).

## Installation

Add `ex_factory` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_factory, "~> 0.1"}
  ]
end
```

Add hook to your CI/CD environment like `http://localhost:4056/redeploy?token=EX_FACTORY_ACCESS_TOKEN`

ExFactory will use your `docker-compose.yml` settings to fetch new version of images and redeployment of containers.

Use `EX_FACTORY_WORKDIR` env variable to set folder of a target `docker-compose.yml`

### Authorization

To enable protected access, set:

```
config :ex_factory, ExFactory.Web.Authorization,
  enabled: true
```

To set access token use either env variable `EX_FACTORY_ACCESS_TOKEN` or
configure it manually:

```
config :ex_factory, ExFactory.Web.Authorization,
  authed_tokens: ["SOME_TOKEN"]
```

### Web access

Default port is `4056`, you can change Cowboy options here:

```
config :ex_factory, ExFactory.Web.Router,
  cowboy_opts: [
    otp_app: :ex_factory,
    port: 4056
  ]
```
