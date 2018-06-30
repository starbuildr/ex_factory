defmodule ExFactory.Supervisor do
  @moduledoc """
  Main application supervisor.
  """

  use Supervisor

  @spec start_link() :: {:ok, pid}
  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init([]) :: {:ok, pid}
  def init([]) do
    children = [
      worker(ExFactory.Web.Router, [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
