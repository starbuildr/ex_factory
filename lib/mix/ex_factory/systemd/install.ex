defmodule Mix.Tasks.ExFactory.Systemd.Install do
  use Mix.Task
  import IO.ANSI

  @service_name "ex_factory"
  @service_local_file "./#{@service_name}.service"
  @service_file "/lib/systemd/system/#{@service_name}.service"

  @doc """
  Install as Debian service.
  """
  def run(_) do
    if File.exists?(@service_local_file) do
      unless File.exists?(@service_file) do
        put_service_file()
      else
        case IO.gets("Service have been already installed as #{@service_name}, replace the existing installation Y[n]?") do
          input when input in ["Y", "Y\n"] ->
            case System.cmd("systemctl", ["stop", "#{@service_name}.service"], stderr_to_stdout: true) do
              {_, 0} ->
                File.rm!(@service_file)
                put_service_file()
                :ok
              {error_message, _exit_code} ->
                IO.puts(error_message)
                :ok
            end
          _ ->
            IO.puts("Leaving an existing installation untouched...")
        end
        :ok
      end
    else
      IO.puts([
        "Run ", cyan(), "mix ex_factory.systemd.prepare FOLDER TOKEN", default_color(),
        " before using this command to prepare service config"
      ])
      :ok
    end
  end

  defp put_service_file() do
    File.rename(@service_local_file, @service_file)
    IO.puts([
      "Service was successfully installed, start with ", cyan(),
      "sudo systemctl start ex_factory.service", default_color(),
      " enable (safe from reboots) with ", cyan(),
      "sudo systemctl enable ex_factory.service", default_color()
    ])
  end
end
