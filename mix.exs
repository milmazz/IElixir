defmodule IElixir.Mixfile do
  use Mix.Project

  def project do
    [app: :ielixir,
     version: "0.9.0-dev",
     source_url: "https://github.com/pprzetacznik/IElixir",
     name: "IElixir",
     elixir: "~> 1.1.0-dev",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "IElixir",
     package: package,
     deps: deps,
     test_coverage: [tool: ExCoveralls]]
  end

  def application do
    [mod: {IElixir, []},
     applications: [:logger, :iex, :sqlite_ecto, :ecto]]
  end

  defp deps do
    [{:erlzmq, github: "zeromq/erlzmq2"},
     {:poison, github: "devinus/poison", override: true},
     {:uuid, github: "okeuday/uuid"},

     {:sqlite_ecto, "~> 0.5.0"},
     {:ecto, "~> 0.15.0"},

     # Docs dependencies
     {:earmark, "~> 0.1", only: :docs},
     {:ex_doc, "~> 0.7", only: :docs},
     {:inch_ex, "0.4.0", only: :docs},

     # Test dependencies
     {:excoveralls, "~> 0.3.11", only: :test}]
  end

  defp package do
     [files: ["config", "lib", "priv", "resources", "mix.exs", "README.md", "LICENSE", "install_script.sh", "start_script.sh", ".travis.yml"],
     contributors: ["Piotr Przetacznik"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/pprzetacznik/ielixir",
              "Docs" => "http://hexdocs.pm/ielixir/"}]
  end
end
