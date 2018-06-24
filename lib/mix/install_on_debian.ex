defmodule Mix.Tasks.InstallOnDebian do
  use Mix.Task

  @service_name "ex_factory"
  @service_file "/lib/systemd/system/#{@service_name}.service"
  @service_content """
[Unit]
Description=Daemon to manage automatic docker-compose redeployments for the new image releases

[Service]
Type=simple
Restart=on-failure
Environment=MIX_ENV=prod
Environment=LANG=en_US.UTF-8

WorkingDirectory=#{System.cwd()}
ExecStart=/usr/local/bin/mix run --no-halt

[Install]
WantedBy=multi-user.target
  """ |> String.trim()

  @doc """
  Install as Debian service.
  """
  def run(service_file) when is_bitstring(service_file) do
    unless File.exists?(service_file) do
      IO.inspect(service_file)
      File.write(service_file, @service_content)
      IO.puts("Service was successfully installed, start with `sudo systemctl restart ex_factory.service`, enable (safe from reboots) with `systemctl enable ex_factory.service`")
    else
      IO.puts("Service have been already installed as #{@service_name}")
      :ok
    end
  end
  def run(_), do: run(@service_file)
end