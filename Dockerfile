FROM elixir:alpine

MAINTAINER Vyacheslav Voronchuk <voronchuk@gmail.com>

RUN mix local.hex --force && mix local.rebar --force

ARG MIX_ENV=prod
ENV MIX_ENV $MIX_ENV

# enable erlang console history
ENV ERL_AFLAGS="-kernel shell_history enabled"

WORKDIR /var/app

COPY ./mix.exs /var/app/mix.exs
COPY ./mix.lock /var/app/mix.lock
COPY ./config /var/app/config
RUN mix do deps.get, deps.compile

# Software
COPY ./lib /var/app/lib

ENTRYPOINT []
CMD ["mix run", "--no-halt"]
