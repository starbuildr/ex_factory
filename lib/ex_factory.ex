defmodule ExFactory do
  @moduledoc """
  Start webserver for external commands.
  """

  use Application

  def start(_type, _args) do
    ExFactory.Web.Router.start_link()
  end
end
