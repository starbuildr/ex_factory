defmodule ExFactory.Web.Authorization do
  def init(opts), do: opts

  def call(conn, _opts) do
    if config(:enabled, false) do
      conn
      |> get_auth_headers
      |> authenticate()
    else
      conn
    end
  end

  def get_auth_headers(conn) do
    tokens =
      with \
        [] <- Plug.Conn.get_req_header(conn, "authorization"),
        token when token != nil <- Plug.Conn.fetch_query_params(conn) |> Map.get("token")
      do
        [token]
      else
        header_tokens when is_list(header_tokens) ->
          header_tokens
        _ ->
          []
      end

    {conn, tokens}
  end

  def authenticate({conn, [token]}) do
    if token in config(:authed_tokens, []) do
      conn
    else
      authenticate({conn, :unauthenticated})
    end
  end
  def authenticate({conn, _}) do
    conn
    |> Plug.Conn.send_resp(401, "Unauthenticated")
    |> Plug.Conn.halt
  end

  defp config(key, default) do
    config = Application.get_env(:ex_factory, ExFactory.Web.Authorization)
    Keyword.get(config, key, default)
  end
end
