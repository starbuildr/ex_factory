defmodule Mix.Tasks.InstallOnDebian do
  use Mix.Task

  @service_name "ex_factory"
  @service_file "/lib/systemd/system/#{@service_name}.service"
  @service_content """
  [Unit]
  Description=Daemon to manage automatic docker-compose redeployments for the new image releases
  
  [Service]
  Type=forking
  Restart=on-failure
  RestartSec=5
  Environment=MIX_ENV=prod
  Environment=LANG=en_US.UTF-8
  Environment=EX_FACTORY_ACCESS_TOKEN=$TOKEN
  Environment=EX_FACTORY_WORKDIR=$WORKDIR
  Environment=HOME=#{System.cwd()}
  
  WorkingDirectory=#{System.cwd()}
  ExecStart=#{System.cwd()}/_build/prod/rel/ex_factory/bin/#{@service_name} start'
  ExecStop=#{System.cwd()}_build/prod/rel/ex_factory/bin/#{@service_name} stop'
  
  [Install]
  WantedBy=multi-user.target
  """ |> String.trim()

  @doc """
  Install as Debian service.
  """
  def run([workdir, token]) do
    System.put_env("EX_FACTORY_WORKDIR", workdir)
    System.put_env("EX_FACTORY_ACCESS_TOKEN", token)
    System.put_env("MIX_ENV", "prod")
    Mix.Tasks.Release.run([])

    if File.dir?(workdir) do
      unless File.exists?(@service_file) do
        IO.inspect(@service_file)
        put_service_file(workdir, token)
      else
        case IO.gets("Service have been already installed as #{@service_name}, replace the existing installation Y[n]?") do
          "Y" ->
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
    IO.puts("First argument should be a folder with docker-compose.yml to target")
    IO.puts("Second argument should be an access token for external access")
    IO.puts("Example: mix install_on_debian /home/user/app jsd9020Adju90!A")
  end

  defp put_service_file(workdir, token) do
    content = @service_content
    |> String.replace("$WORKDIR", workdir)
    |> String.replace("$TOKEN", token)
    File.write(@service_file, content)

    IO.puts("Service was successfully installed, start with `sudo systemctl restart ex_factory.service`, enable (safe from reboots) with `systemctl enable ex_factory.service`")
  end
end
