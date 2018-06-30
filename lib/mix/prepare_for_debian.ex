defmodule Mix.Tasks.PrepareForDebian do
  use Mix.Task
  import IO.ANSI

  @erlang_cookie :crypto.strong_rand_bytes(10) |> Base.encode64()
  @service_name "ex_factory"
  @service_local_file "./#{@service_name}.service"
  @service_content """
  [Unit]
  Description=Daemon to manage automatic docker-compose redeployments for the new image releases
  After=network.target
  Requires=network.target
  
  [Service]
  Type=forking
  Restart=on-failure
  RestartSec=5
  User=$USER
  Group=$GROUP
  Environment=MIX_ENV=prod
  Environment=LANG=en_US.UTF-8
  Environment=REPLACE_OS_VARS=true
  Environment=COOKIE=#{@erlang_cookie}
  Environment=EX_FACTORY_ACCESS_TOKEN=$TOKEN
  Environment=EX_FACTORY_WORKDIR=$WORKDIR
  Environment=HOME=#{System.cwd()}
  
  WorkingDirectory=#{System.cwd()}
  ExecStart=#{System.cwd()}/_build/prod/rel/ex_factory/bin/#{@service_name} start
  ExecStop=#{System.cwd()}/_build/prod/rel/ex_factory/bin/#{@service_name} stop
  SyslogIdentifier=#{@service_name}
  RemainAfterExit=yes
  
  [Install]
  WantedBy=multi-user.target
  """ |> String.trim()

  @doc """
  Prepare service config for a Debian system installation.
  """
  def run([workdir, token]) do
    run([workdir, token, "ubuntu", "docker"])
  end
  def run([workdir, token, user, group]) do
    System.put_env("EX_FACTORY_WORKDIR", workdir)
    System.put_env("EX_FACTORY_ACCESS_TOKEN", token)
    System.put_env("MIX_ENV", "prod")
    System.put_env("COOKIE", @erlang_cookie)

    Mix.Task.run("release", ["--env", "prod"])

    if File.dir?(workdir) and File.exists?("#{workdir}/docker-compose.yml") do
      content = @service_content
      |> String.replace("$WORKDIR", workdir)
      |> String.replace("$TOKEN", token)
      |> String.replace("$USER", user)
      |> String.replace("$GROUP", group)
      File.write(@service_local_file, content)
  
      IO.puts("Generating service config file to #{@service_local_file}...")
      IO.puts(["Run ", cyan(), "sudo MIX_ENV=prod mix install_on_debian", default_color(), " to finish the installation."])
      :ok
    else
      IO.puts(["First param should be the folder where a target ", cyan(), "docker-compose.yml", default_color(), " is stored"])
      :ok
    end
  end
  def run(_) do
    random_token = :crypto.strong_rand_bytes(12) |> Base.encode64() |> String.to_charlist()
    IO.puts("First argument should be a folder with docker-compose.yml to target")
    IO.puts("Second argument should be an access token for external access")
    IO.puts("Third and forth optional arguments (default are ubuntu) are a user and security group to start this daemon from")
    IO.puts(["Example: ", cyan(), "MIX_ENV=prod mix prepare_for_debian /home/user/app #{random_token}", default_color()])
  end
end
