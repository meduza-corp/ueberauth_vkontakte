defmodule Ueberauth.Strategy.Vkontakte do
  require Logger
  @moduledoc """
  Vkontakte Strategy for Überauth.
  """

  use Ueberauth.Strategy, default_scope: "email",
                          profile_fields: "",
                          uid_field: :id,
                          allowed_request_params: [
                            :auth_type,
                            :scope,
                          ]


  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  @doc """
  Handles initial request for Vkontakte authentication.
  """
  def handle_request!(conn) do
    allowed_params = conn
     |> option(:allowed_request_params)
     |> Enum.map(&to_string/1)

    authorize_url = conn.params
      |> maybe_replace_param(conn, "auth_type", :auth_type)
      |> maybe_replace_param(conn, "scope", :default_scope)
      |> Enum.filter(fn {k,_v} -> Enum.member?(allowed_params, k) end)
      |> Enum.map(fn {k,v} -> {String.to_existing_atom(k), v} end)
      |> Keyword.put(:redirect_uri, callback_url(conn))
      |> Ueberauth.Strategy.Vkontakte.OAuth.authorize_url!

    redirect!(conn, authorize_url)
  end

  @doc """
  Handles the callback from Vkontakte.
  """
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    opts = [
      redirect_uri: callback_url(conn),
      client_id: Ueberauth.Strategy.Vkontakte.OAuth.client.client_id,
      client_secret: Ueberauth.Strategy.Vkontakte.OAuth.client.client_secret,
    ]
    token = Ueberauth.Strategy.Vkontakte.OAuth.get_token!([code: code], opts)

    if token.access_token == nil do
      err = token.other_params["error"]
      desc = token.other_params["error_description"]
      set_errors!(conn, [error(err, desc)])
    else
      fetch_user(conn, token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:vkontakte_user, nil)
    |> put_private(:vkontakte_token, nil)
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    uid_field =
      conn
      |> option(:uid_field)
      |> to_string

    conn.private.vkontakte_user[uid_field]
  end

  @doc """
  Includes the credentials from the vkontakte response.
  """
  def credentials(conn) do
    token = conn.private.vkontakte_token
    scopes = token.other_params["scope"] || ""
    scopes = String.split(scopes, ",")

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: scopes,
      token: token.access_token
    }
  end

  @doc """
  Fetches the fields to populate the info section of the
  `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.vkontakte_user

    %Info{
      description: user["bio"],
      email: user["email"],
      first_name: user["first_name"],
      image: user["avatar"],
      last_name: user["last_name"],
      name: user["name"],
      urls: %{
        vkontakte: user["link"],
        website: user["website"]
      }
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from
  the vkontakte callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.vkontakte_token,
        user: conn.private.vkontakte_user
      }
    }
  end

  defp fetch_user(conn, token) do
    conn = put_private(conn, :vkontakte_token, token)

    %{
      other_params: %{
        "user_id" => user_id
      }
    } = conn.private.vkontakte_token

    email = case conn.private.vkontakte_token do
      %{
        other_params: %{
          "email" => email
        }
      } -> email
      _ -> nil
    end

    url = "https://api.vk.com/method/users.get?user_id=#{user_id}&fields=photo_50&v=5.50&access_token=#{token}"

    case OAuth2.AccessToken.get(token, url) do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])
      {:ok, %OAuth2.Response{status_code: status_code, body: body}}
        when status_code in 200..399 ->
        %{"response" => [user] } = body
        user = Map.merge(user, %{"id" => "#{user_id}", "email" => email, "avatar" => user["photo_50"]})
        put_private(conn, :vkontakte_user, user)
      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end


  # This is left from ueberauth_facebook
  # vk has a different strategy to get user data
  # defp user_query(conn) do
  #   conn
  #   |> Map.merge(query_params(conn, :profile))
  #   |> URI.encode_query
  # end

  # defp query_params(conn, :profile) do
  #   %{"fields" => option(conn, :profile_fields)}
  # end
  # defp query_params(conn, :locale) do
  #   case option(conn, :locale) do
  #     nil -> %{}
  #     locale -> %{"locale" => locale}
  #   end
  # end

  defp option(conn, key) do
    default = Dict.get(default_options, key)

    conn
    |> options
    |> Dict.get(key, default)
  end
  defp option(nil, conn, key), do: option(conn, key)
  defp option(value, _conn, _key), do: value

  defp maybe_replace_param(params, conn, name, config_key) do
    if params[name] do
      params
    else
      Map.put(
        params,
        name,
        option(params[name], conn, config_key)
      )
    end
  end
end
