defmodule ExFactory.Util.Cmd do
  @moduledoc """
  Utility commands to work with command line.
  """

  @type generic_response :: :ok | :error

  @doc """
  Execute shell command with a generic response.
  """
  @spec exec(String.t, [String.t]) :: generic_response
  def exec(command, args) do
    case System.cmd(command, args, stderr_to_stdout: true) do
      {_, 0} ->
        :ok
      {error_message, _exit_code} ->
        IO.puts(error_message)
        :error
    end
  end
end
