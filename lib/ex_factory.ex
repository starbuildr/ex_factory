defmodule ExFactory do
  @moduledoc """
  Start webserver for external commands.
  """

  use Application

  def start(_type, _args), do: ExFactory.Supervisor.start_link()
end
