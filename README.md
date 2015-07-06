# blockytalky_elixir
Phoenix and Elixir version of BlockyTalky for Raspberry pi -- LPC

#To Install for development
You will need the following programs:
- Vagrant
- ChefDK
- VirtualBox (Or VM Ware)

You will also need the following vagrant plugins:
- vagrant-berkshelf (>= 4.0.4)
- vagrant-share     (>= 1.1.3, system)
- vagrant-triggers  (>= 0.5.0)
- vagrant-vbguest   (>= 0.10.0)

You can install the plugins with: `vagrant plugin install <plugin-name>``

#To Install on raspberry pi
- install erlang
  - `https://www.erlang-solutions.com/downloads/download-erlang-otp`
  - install the full erlang, not erlang-mini
- install npm
  - wget http://node-arm.herokuapp.com/node_latest_armhf.deb
  - sudo dpkg -i node_latest_armhf.deb
    - thanks to: `http://weworkweplay.com/play/raspberry-pi-nodejs/`
- install elixir from source
  - git clone "https://github.com/elixir-lang/elixir"
  - git checkout "tags/v1.0.5"
    - or other current version of elixir
  - make clean test
    - note: test takes a while, you can just run clean if you have done these steps before without changing versions / environments
  - sudo make install
    - this step also takes a while.
- install hex
  - mix local.hex
- install phoenix tasks
  - `sudo mix archive.install https://github.com/phoenixframework/phoenix/releases/download/v0.14.0/phoenix_new-0.14.0.ez`
  - replace the v number with whatever version of pheonix blockytalky currently has
- run npm in case brunch isn't working
  - cd blockytalky_elixir/blockytalky
  - npm install
    - You also may need to run `npm install node-sass` separately because of a bad github link.
- install blockytalky deps
  - (cd blockytalky_elixir/blockytalky)
  - sudo mix deps.get
  - sudo mix compile
- install python
  - sudo apt-get install python-dev
  - sudo apt-get install python-pip
- install python deps for brick pi and file logging setup  mix tasks
  - (cd blockytalky_elixir/blockytalky)
  - sudo mix pythonDeps
    - installs brickpi and grovepi python drivers onto your rpi
  - sudo mix fileLogging
    - sets up syslog to have a blockytalky.log file in `/var/logs`
- optional dev tools
  - `sudo apt-get install inotify-tools`

  # Run
  - `sudo MIX_ENV=prod PORT=80 mix phoenix.server`
  - run with REPL:
    - `sudo MIX_ENV=prod PORT=80 iex -S mix phoenix.server`
