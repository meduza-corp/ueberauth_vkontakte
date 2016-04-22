defmodule UeberauthVkontakte.Mixfile do
  use Mix.Project

  @version "0.3.2"
  @url "https://github.com/meduza/ueberauth_vkontakte"

  def project do
    [app: :ueberauth_vkontakte,
     version: @version,
     name: "Ueberauth Vkontakte Strategy",
     package: package,
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: @url,
     homepage_url: @url,
     description: description,
     deps: deps,
     docs: docs]
  end

  def application do
    [applications: [:logger, :oauth2, :ueberauth]]
  end

  defp deps do
    [{:ueberauth, "~> 0.2"},
     {:oauth2, "~> 0.5"},
     {:ex_doc, "~> 0.1", only: :dev},
     {:earmark, ">= 0.0.0", only: :dev},
     {:dogma, ">= 0.0.0", only: [:dev, :test]}]
  end

  defp docs do
    [extras: docs_extras, main: "extra-readme"]
  end

  defp docs_extras do
    ["README.md"]
  end

  defp description do
    "An Uberauth strategy for Vkontakte authentication."
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Boris Goriachev"],
      licenses: ["MIT"],
      links: %{"GitHub": @url}]
  end
end
