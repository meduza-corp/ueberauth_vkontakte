defmodule Ueberauth.Strategy.Vkontakte.OAuth do
  @moduledoc """
  OAuth2 for Vkontakte.

  Add `client_id` and `client_secret` to your configuration:

  config :ueberauth, Ueberauth.Strategy.Vkonakte.OAuth,
    client_id: System.get_env("VKONTAKTE_APP_ID"),
    client_secret: System.get_env("VKONTAKTE_APP_SECRET")
  """
  use OAuth2.Strategy

  @defaults [
    strategy: __MODULE__,
    site: "https://oauth.vk.com/",
    authorize_url: "https://oauth.vk.com/authorize",
    token_url: "/oauth/access_token",
  ]

  @doc """
  Construct a client for requests to Vkonakte.

  This will be setup automatically for you in `Ueberauth.Strategy.Vkontakte`.
  These options are only useful for usage outside the normal callback phase
  of Ueberauth.
  """
  def client(opts \\ []) do
    config = Application.get_env(:ueberauth, Ueberauth.Strategy.Vkontakte.OAuth)

    opts =
      @defaults
      |> Keyword.merge(config)
      |> Keyword.merge(opts)

    OAuth2.Client.new(opts)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth.
  No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.get_token!(params)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
