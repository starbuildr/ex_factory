defmodule Mix.Tasks.Docker.Compose.PullNewImages do
  use Mix.Task
  import ExFactory.Util.Cmd

  @doc """
  Fetch the current version of images from Docker hub.
  """
  def run(_) do
    command = "docker-compose"
    args = ["pull"]
    exec(command, args)
  end
end
