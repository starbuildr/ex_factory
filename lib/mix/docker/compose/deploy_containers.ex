defmodule Mix.Tasks.Docker.Compose.DeployContainers do
  use Mix.Task
  import ExFactory.Util.Cmd

  @doc """
  Create and run the new containers from latest local images.
  """
  def run(_) do
    command = "docker-compose"
    args = ["up", "-d"]
    exec(command, args)
  end
end
