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

Start the vm with:
`vagrant up`
If running on windows, please use a shell (like cygwin or the git-portable with sourcetree) that has ssh. Also, run the shell as an Administrator.
If running on windows, after initializing for the first time, restart windows as that is required for symlinks to work (which is important for npm packages like brunch.io)
- Install brunch io and npm
  - `cd blockytalky`
  - `rm -rf node_modules`
      - NOTE: for vagrant, you need to make a symlink to somewhere not shared so that the folder name being too long doesn't crash: `mkdir ~/node_modules && ln -s ~/node_modules node_modules`
  - `npm install`
  - `sudo npm install -g brunch`
- install mix packages:
  -  `mix local.hex`
  -  `mix deps.get`
#To Install on raspberry pi or by hand on vm:
- install erlang
  - `https://www.erlang-solutions.com/downloads/download-erlang-otp`
  - install the full erlang, not erlang-mini
- install npm
  - wget http://node-arm.herokuapp.com/node_latest_armhf.deb
  - sudo dpkg -i node_latest_armhf.deb
    - thanks to: `http://weworkweplay.com/play/raspberry-pi-nodejs/`
    - note, if on vm or rpi if you have npm problems consider:
      - `wget https://www.npmjs.com/install.sh | sudo sh` to see if that installs a more up to date version
- install elixir from source
  - git clone "https://github.com/elixir-lang/elixir"
  - git checkout "tags/v1.0.5"
    - or other current version of elixir ~>1.0.4
  - make clean test
    - note: test takes a while, you can just run clean if you have done these steps before without changing versions / environments
  - sudo make install
    - this step also takes a while.
- install hex
  - `sudo mix local.hex`
- install phoenix tasks
  - `sudo mix archive.install` https://github.com/phoenixframework/phoenix/releases/download/v0.14.0/phoenix_new-0.14.0.ez`
  - replace the v number with whatever version of pheonix blockytalky currently has
- run npm in case brunch isn't working
  - cd blockytalky_elixir/blockytalky
  - `rm -rf node_modules` if any exist currently
  - `sudo npm cache clean`
  - `sudo npm install`
  - `sudo npm install -g brunch`
    - use `npm list` to see what might be missing.
- install blockytalky deps
  - (cd blockytalky_elixir/blockytalky)
  - `sudo mix deps.get`
  - `sudo mix compile`
- run `chmod +x install.sh && sudo install.sh` from DexterInd.
  - `https://github.com/DexterInd/BrickPi/tree/master/Setup%20Files`
- install BrickPi library globally (optional, we have a version in the hw_api directory)
  - `https://github.com/DexterInd/BrickPi_Python`
  - `sudo python setup.py install`
- enable logging
  - (cd blockytalky_elixir/blockytalky)
  - sudo mix fileLogging
- optional dev tools
  - `sudo apt-get install inotify-tools`

# Run for dev
  - `sudo HOSTNAME=<blockytalky_id> mix phoenix.server` or `sudo HOSTNAME=<blockytalky_id> iex -S mix phoenix.server` if you want iex>
    - where you replace the blockytalky_id with the id that you want to run as (for messaging, etc.) if you want to use a btu id other than your hostname
    - make sure to change the dev config options (specifically supported hardware) if you are deving on the pi and want to test brickpi or grovepi support
# Deploy for production
    - resource: http://www.phoenixframework.org/v0.14.0/docs/advanced-deployment
    - on dev machine: `sudo brunch build --production && sudo MIX_ENV=prod mix release` will generate a new /rel folder
      - I do not currently recommend building a release on the pi itself because `brunch build --production` seems to take too long or hang
      - you can run `npm list` to make sure brunch will succeed in its build. if you are missing dependencies, then node install did not work correctly. This is a big issue on VMs and the solution of making the node_modules dir a symlink to somewhere else on the system (not a windows file system).
    - on raspberry pi: `sudo mix blockytalky.deploy` which automates:
      - pulls the blockytalky release that matches the current version in mix.exs
      - puts it in startup
