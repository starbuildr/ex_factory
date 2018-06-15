defmodule ExFactory.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_factory,
      version: "0.1.0",
      elixir: "~> 1.5",
      description: "Elixir library to manage automatic docker-compose redeployments for new docker images",
      docs: [extras: ["README.md"]],
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package()
    ]
  end

  def package do
    [
      name: :ex_factory,
      files: ["lib", "mix.exs"],
      maintainers: ["Vyacheslav Voronchuk"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/starbuildr/ex_factory"},
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ExFactory, []},
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/factories"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.0"}
    ]
  end

  defp aliases do
    [
      "redeploy": [
        "docker.compose.pull_new_images",
        "docker.compose.stop_containers",
        "docker.compose.deploy_contrainers"
      ],
      "test": ["test"]
    ]
  end
end
