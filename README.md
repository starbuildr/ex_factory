# ExFactory

Automatic redeployment system for `docker-compose`.

[Hex docs](https://hexdocs.pm/ex_factory).

## Installation

Make sure that Elixir and Erlang with their dependencies are both installed on your current system.

Add hook to your CI/CD environment like `http://localhost:4056/redeploy?token=EX_FACTORY_ACCESS_TOKEN`

ExFactory will use your `docker-compose.yml` settings to fetch new version of images and redeployment of containers.

Use `EX_FACTORY_WORKDIR` env variable to set folder of a target `docker-compose.yml`

### Ubuntu
To use private docker images you need to authorise on docker hub first with `docker login` (step 2),
then create a symlink (step 3), because $HOME variable will be overridden in ex_factory service.

Default user is `ubuntu`, default group is `docker`, pass custom names as
third and fourth argument of `ex_factory.systemd.prepare` mix command (step 4).

1. `cd ~/ && git clone https://github.com/starbuildr/ex_factory.git`
2. `docker login`
3. `ln -s ~/.docker ~/ex_factory/.docker`
4. `MIX_ENV=prod mix ex_factory.systemd.prepare [COMPOSE_WORKDIR] [EX_FACTORY_ACCESS_TOKEN]`
5. `sudo MIX_ENV=prod mix install_on_debian`
6. `sudo systemctl start ex_factory.service`

#### Troubleshooting

* `sudo systemctl stop ex_factory.service`
* `sudo rm -R _build`
* `MIX_ENV=prod mix prepare_for_debian [COMPOSE_WORKDIR] [EX_FACTORY_ACCESS_TOKEN]`
* `sudo MIX_ENV=prod mix ex_factory.systemd.installn`
* `sudo systemctl daemon-reload`
* `sudo systemctl start ex_factory.service`

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
