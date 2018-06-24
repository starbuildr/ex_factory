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
  Environment=EX_FACTORY_ACCESS_TOKEN=$TOKEN
  Environment=EX_FACTORY_WORKDIR=$WORKDIR
  Environment=HOME=#{System.cwd()}
  
  WorkingDirectory=#{System.cwd()}
  ExecStart=/usr/local/bin/mix run --no-halt
  
  [Install]
  WantedBy=multi-user.target
  """ |> String.trim()

  @doc """
  Install as Debian service.
  """
  def run([workdir, token]) do
    if File.dir?(workdir) do
      unless File.exists?(@service_file) do
        IO.inspect(@service_file)
        put_service_file(workdir, token)
      else
        case IO.gets("Service have been already installed as #{@service_name}, replace the existing installation Y[n]?") do
          confirm when confirm in ["Y", "Y\n"] ->
            put_service_file(workdir, token)
          _ ->
            IO.puts("Leaving existing installation untouched...")
        end
        :ok
      end
    else
      IO.puts("First param should be the folder where a target docker-compose.yml is stored")
      :ok
    end
  end
  def run(_) do
    """
    First argument should be a folder with #{IO.ANSI.format([:black_background, :red, "docker-compose.yml"])} to target
    Second argument should be an #{IO.ANSI.format([:black_background, :red, "access token"])} for external access

    Example: #{IO.ANSI.format([:black_background, :cyan, "mix install_on_debian /home/user/app jsd9020Adju90aVcc2"])}
    """ |> IO.puts()
  end

  defp put_service_file(workdir, token) do
    content = @service_content
    |> String.replace("$WORKDIR", workdir)
    |> String.replace("$TOKEN", token)
    File.write(@service_file, content)

    IO.puts("Service was successfully installed, start with `sudo systemctl restart ex_factory.service`, enable (safe from reboots) with `systemctl enable ex_factory.service`")
  end
end
