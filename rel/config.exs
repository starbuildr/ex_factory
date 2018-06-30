use Mix.Releases.Config,
  default_release: :default,
  default_environment: :dev

environment :dev do
  set dev_mode: true
  set include_erts: false
end

environment :prod do
  set include_erts: true
  set include_src: true
  set cookie: System.get_env("COOKIE")
end

release :ex_factory do
  set version: current_version(:ex_factory)
end
