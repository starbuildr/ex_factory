defmodule Mix.Tasks.Docker.Compose.StopContainers do
  use Mix.Task
  import ExFactory.Util.Cmd

  @doc """
  Stop and destroy currently running containers.
  """
  def run(_) do
    command = "docker-compose"
    args = ["pull"]
    exec(command, args)
  end
end
