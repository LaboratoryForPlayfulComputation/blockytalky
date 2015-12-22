####
#Custom setup
defmodule Mix.Tasks.PythonDeps do
  use Mix.Task
  def run(_) do
    Mix.shell.info "Installing python dependencies for brickpi and grovepi"
    HTTPoison.start
    unless is_sudo, do: Mix.raise "This mix task needs to be run with sudo to install python dependencies globally"
    unless easy_install, do: Mix.raise "Unable to find easy install, please update to latest python for pip and easy_install"
    unless is_git_installed, do: Mix.raise "Git is required to download the brickpi and grovepi repos"
    unless is_internet_on, do: Mix.raise "Unable to connect to the internet."
    unless is_raspberrypi, do: Mix.raise "Quiting without installing python dependencies."
    install_python_deps
  end
  defp is_sudo do
    {user,_} = System.cmd "whoami", []
    user = String.strip user
    Mix.shell.info "Currently running as: #{IO.ANSI.format([:blue,user],true)} user"
    user == "root"
  end
  defp easy_install do
    Mix.shell.info "Checking if easy_install is installed"
    System.find_executable("easy_install")
  end
  defp is_raspberrypi do
    Mix.shell.yes?("""
             You should only install these python dependencies on raspberry pi
             Are you on a raspberry pi?
             """
            )
  end
  defp is_internet_on do
    Mix.shell.info "Checking if internet is connected to download dependencies using easy_install / pip"
    case HTTPoison.get("https://www.github.com") do
      {:ok, _ } ->
        true
      _ ->
        false
    end
  end
  defp is_git_installed do
    System.find_executable("git")
  end
  defp install_python_deps do
    Mix.shell.info "Installing requests[security] via pip if need be."
    System.cmd("pip", ["install","requests[security]"])
    Mix.shell.info "Installing smbus"
    if System.find_executable("apt-get"), do: System.cmd("apt-get", ["install", "-y", "python-smbus"])
    Mix.shell.info "Fetching setup.py for Brickpi from github"
    deps_dir = "#{System.tmp_dir}/bt_python_deps"
    File.mkdir_p(deps_dir)
    System.cmd("git", ["clone","https://github.com/DexterInd/BrickPi_Python.git", "#{deps_dir}/brickpi"])
    System.cmd("git", ["clone", "https://github.com/DexterInd/GrovePi.git", "#{deps_dir}/grovepi"])
    Mix.shell.info "Installing Brick Pi globally"
    System.cmd "python", ["setup.py", "install"], [cd: "#{deps_dir}/brickpi/"]
    Mix.shell.info "Installing Grove Pi globally"
    System.cmd "python", ["setup.py", "install"], [cd: "#{deps_dir}/grovepi/Software/Python/"]
    # copy for local use: such as reading constants.
    System.cmd "cp", ["#{deps_dir}/brickpi/BrickPi.py", Application.app_dir(:blockytalky, "priv/hw_apis")]
    System.cmd "cp", ["#{deps_dir}/grovepi/Software/Python/grovepi.py","#{__DIR__}/../hw_apis"]

    Mix.shell.info "Done! Cleaning up..."
  end
end

defmodule Mix.Tasks.FileLogging do
  use Mix.Task
  def run(_) do
    Mix.shell.info "Configuring file logging using rsyslog #{IO.ANSI.format([:blue,"(Debian/Ubuntu systems supported)"])}"
    unless is_sudo, do: Mix.raise "This mix task needs to be run with sudo to copy #{IO.ANSI.format([:blue,"/etc/rsyslog.d"])} files"
    if File.exists?("/etc/rsyslog.d") do
      System.cmd("cp", ["#{__DIR__}/blockytalky-log.conf","/etc/rsyslog.d"])
      System.cmd("cp", ["#{__DIR__}/bt_logrotation_script.sh","/etc/rsyslog.d"])
      System.cmd("chmod", ["+x","/etc/rsyslog.d/bt_logrotation_script.sh"])
      Mix.shell.info "Setting up File Logging: Done!"
    end

  end
  defp is_sudo do
    {user,_} = System.cmd "whoami", []
    user = String.strip user
    Mix.shell.info "Currently running as: #{IO.ANSI.format([:blue,user],true)} user"
    user == "root"
  end
end
defmodule Mix.Tasks.Blockytalky.Release do
  use Mix.Task
  def run(_) do
    System.put_env(%{"MIX_ENV"=>"prod"})
    Mix.shell.info "Compiling Blockytalky with prod environment"
    System.cmd("mix",["compile"])
    Mix.shell.info "Preparing Blockytalky for release: brunch build + phoenix digest"
    System.cmd("brunch",["build","--production"],into: IO.stream(:stdio, :line))
    System.cmd("mix",["phoenix.digest"],into: IO.stream(:stdio, :line))
    Mix.shell.info "Running EXRM release"
    System.cmd("mix",["release","--no-confirm-missing", "--verbosity=verbose"],into: IO.stream(:stdio, :line))
  end
end
