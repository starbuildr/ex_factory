defmodule ExFactory.Web.Router do
  @moduledoc """
  Router for webhooks.
  """
  
  use Plug.Router
  use Plug.ErrorHandler
  alias ExFactory.Web.ActionPlug
  require Logger

  plug ExFactory.Web.Authorization
  plug :match
  plug :dispatch

  def start_link do
    config = Application.get_env(:ex_factory, ExFactory.Web.Router)
    opts = Keyword.get(config, :cowboy_opts, [])
    Plug.Adapters.Cowboy.http(ExFactory.Web.Router, [], opts)
  end

  get "/" do
    send_resp(conn, 200, "Plug!")
  end
  get "/redeploy", to: ActionPlug.Redeploy

  match "*any" do
    send_resp(conn, 404, "Not Found")
  end

  defp handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    Logger.debug fn() -> "Invalid request: #{inspect(reason)}, #{inspect(kind)}, #{inspect(stack)}" end
    send_resp(conn, 500, "Internal server error")
  end
end
