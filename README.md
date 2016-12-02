# This is not being actively supported, consider using https://github.com/sobolevn/ueberauth_vk instead.

# Überauth vkontakte

[license]: http://opensource.org/licenses/MIT

> vkontakte OAuth2 strategy for Überauth.

## Installation

1. Setup your application at [vkontakte Developers](https://vk.com/dev/auth_sites).

1. Add `:ueberauth_vkontakte` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_vkontakte, "~> 0.1"}]
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
      client_id: System.get_env("VKONTAKTE_CLIENT_ID"),
      client_secret: System.get_env("VKONTAKTE_CLIENT_SECRET")
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

```elixir
config :ueberauth, Ueberauth,
  providers: [
    vkontakte: {Ueberauth.Strategy.vkontakte, [default_scope: "email"]}
  ]
```

## License

Please see [LICENSE](https://github.com/ueberauth/ueberauth_vkontakte/blob/master/LICENSE) for licensing details.

