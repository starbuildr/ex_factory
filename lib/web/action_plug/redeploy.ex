defmodule ExFactory.Web.ActionPlug.Redeploy do
  @moduledoc """
  Execute docker compose redeployment pipeline.
  """

  alias Mix.Tasks.Docker.Compose
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    workdir = System.get_env("EX_FACTORY_WORKDIR") || File.cwd!()
    with \
      true <- File.exists?("#{workdir}/docker-compose.yml"),
      {:pull_new_images, :ok} <- {:pull_new_images, Compose.PullNewImages.run([])},
      {:stop_containers, :ok} <- {:stop_containers, Compose.StopContainers.run([])},
      {:deploy_containers, :ok} <- {:deploy_containers, Compose.DeployContainers.run([])}
    do
      send_resp(conn, 200, "Containers redeployed!")
    else
      false ->
        send_resp(conn, 404, "docker-compose.yml doesn't exist")
      {:pull_new_images, errors} ->
        Logger.error fn -> "Pull: " <> inspect(errors) end
        send_resp(conn, 500, "Failed to pull new image versions")
      {:stop_containers, errors} ->
        Logger.error fn -> "Stop: " <> inspect(errors) end
        send_resp(conn, 500, "Failed to stop and destroy old containers")
      {:deploy_containers, errors} ->
        Logger.error fn -> "Deploy: " <> inspect(errors) end
        send_resp(conn, 500, "Failed to deploy and start new containers")
    end
  end
end
