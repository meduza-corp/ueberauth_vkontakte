# Überauth vkontakte
[![Build Status][travis-img]][travis] [![Hex Version][hex-img]][hex] [![License][license-img]][license]

[travis-img]: https://travis-ci.org/ueberauth/ueberauth_vkontakte.png?branch=master
[travis]: https://travis-ci.org/ueberauth/ueberauth_vkontakte
[hex-img]: https://img.shields.io/hexpm/v/ueberauth_vkontakte.svg
[hex]: https://hex.pm/packages/ueberauth_vkontakte
[license-img]: http://img.shields.io/badge/license-MIT-brightgreen.svg
[license]: http://opensource.org/licenses/MIT

> vkontakte OAuth2 strategy for Überauth.

## Installation

1. Setup your application at [vkontakte Developers](https://developers.vkontakte.com).

1. Add `:ueberauth_vkontakte` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_vkontakte, "~> 0.3"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_vkontakte]]
    end
    ```

1. Add vkontakte to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        vkontakte: {Ueberauth.Strategy.vkontakte, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.vkontakte.OAuth,
      client_id: System.get_env("vkontakte_CLIENT_ID"),
      client_secret: System.get_env("vkontakte_CLIENT_SECRET")
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

1. You controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initial the request through:

    /auth/vkontakte

Or with options:

    /auth/vkontakte?scope=email,public_profile

By default the requested scope is "public_profile". Scope can be configured either explicitly as a `scope` query value on the request path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    vkontakte: {Ueberauth.Strategy.vkontakte, [default_scope: "email,public_profile,user_friends"]}
  ]
```

Starting with Graph API version 2.4, vkontakte has limited the default fields returned when fetching the user profile.
Fields can be explicitly requested using the `profile_fields` option:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    vkontakte: {Ueberauth.Strategy.vkontakte, [profile_fields: "name,email,first_name,last_name"]}
  ]
```

See [Graph API Reference > User](https://developers.vkontakte.com/docs/graph-api/reference/user) for full list of fields.


## License

Please see [LICENSE](https://github.com/ueberauth/ueberauth_vkontakte/blob/master/LICENSE) for licensing details.

