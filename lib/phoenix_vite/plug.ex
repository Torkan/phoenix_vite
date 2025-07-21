defmodule PhoenixVite.Plug do
  def favicon(conn, opts) do
    with "/favicon.ico" <- conn.request_path,
         {m, f, a} <- Keyword.get(opts, :dev_server),
         true <- apply(m, f, a) do
      endpoint = Phoenix.Controller.endpoint_module(conn)

      uri =
        endpoint.static_url()
        |> URI.new!()
        |> URI.append_path("/favicon.ico")
        |> URI.to_string()

      conn
      |> Phoenix.Controller.redirect(external: uri)
      |> Plug.Conn.halt()
    else
      _ -> conn
    end
  end
end
