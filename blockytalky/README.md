# Blockytalky
## For Developers
1. Install dependencies with `mix deps.get`
2. Start blockytalky endpoint with `mix phoenix.server`
3. To start blockytalky endpoint with iex> run `sudo iex -S mix phoenix.server`
4. Optionally, you can change the environment (currently dev, test, and prod) with `sudo MIX_ENV=prod PORT=8080 iex -S mix phoenix.server`. You will need to specify a port in prod mode. port is 4000 in dev and test.
5. If you get module.js errors, it means brunch (nodejs) did not install correcly, please run: `npm install` in this directory
6. For running on raspberry pi with  hardware, you will need python dependencies. install them with `sudo mix PythonDeps`
Now you can visit `localhost:4000` from your browser.
