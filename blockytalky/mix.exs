defmodule Blockytalky.Mixfile do
  use Mix.Project

  def project do
    [app: :blockytalky,
     version: "0.2.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {Blockytalky, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger,
                    :phoenix_ecto, :postgrex, :httpoison, :syslog,
                    :erlport,:osc, :exjsx, :socket, :crypto]]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 0.14", override: true},
     {:phoenix_ecto, "~> 0.4"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 1.1"},
     {:phoenix_live_reload, "~> 0.4", only: :dev},
     {:cowboy, "~> 1.0"},
     {:erlport, git: "https://github.com/hdima/erlport.git"},
     {:osc,     git: "https://github.com/mujaheed/erlang-osc.git"},
     {:httpoison, "~> 0.7"},
     {:syslog, git: "https://github.com/smpallen99/syslog.git"},
     { :exjsx, git: "https://github.com/talentdeficit/exjsx.git" },
     { :socket, git: "https://github.com/meh/elixir-socket.git"},
     {:exrm, git: "https://github.com/bitwalker/exrm.git", tag: "0.18.5"}
   ]
  end
end
