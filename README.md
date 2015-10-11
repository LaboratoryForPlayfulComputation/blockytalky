# BlockyTalky
BlockyTalky is a distributed, networked toolkit for programming IoT like devices.

BlockyTalky runs as a DSL and runtime-system wrapped by a phoenix web app that provides real-time monitoring of hardware signals, a Google Blockly based visual programming interface, and typical IDE functions like running and stopping code.

BlockyTalky expects to be installed on Raspberry Pi hardware and currently supports Raspbian, Coder, and [DexterInd's Modified Raspbian](http://www.dexterindustries.com/BrickPi/getting-started/pi-prep/)

BlockyTalky currently supports the domains of Sensors and Motors with driver support for BrickPi and GrovePi hats and hardware. SonicPi's softsynth DSL is also supported on Pi2s or better.

# Quick Install
Checklist:
- Install Latest BlockyTalky release and run on boot
- BrickPi and GrovePi setup
- SonicPi run on start and boot in GUI Modified

### Install (or Upgrade) Latest BlockyTalky release and run on boot

<pre>
mkdir /opt/blockytalky
cd /opt/blockytalky
# wget or curl the latest release, replace the version #
# https://github.com/tufts-LPC/blockytalky_elixir/releases/latest
sudo wget https://github.com/tufts-LPC/blockytalky_elixir/releases/download/v#.#.#/blockytalky.tar.gz
sudo tar xvfz blockytalky.tar.gz
# edit the config to enable / disable music and specific hardware
sudo nano releases/#.#.#/blockytalky.conf
# add: /opt/blockytalky/bin/blockytalky start
sudo nano /etc/rc.local
</pre>

### BrickPi and GrovePi Setup
From your home or some other directory:
<pre>
git clone https://github.com/DexterInd/BrickPi_Python
cd BrickPi_Python
sudo apt-get install python-setuptools
sudo python setup.py install
</pre>

Edit `/boot/config.txt` and uncomment the line: `dtparam=i2c_arm=on`

### SonicPi run on start and boot in GUI Modified

Edit `/etc/xdg/lxsession/LXDE-pi/autostart` and add the line `@sonicpi`

Run `sudo raspi-config` and enable boot to desktop GUI mode.


# More Instructions
When installing on coder, both blockytalky and coder will compete for port 80. Please make your coder configuration use another port.

To get started with developing for BlockyTalky:
[Start here for Development Instructions](https://github.com/tufts-LPC/blockytalky_elixir/wiki/Getting-Started-for-Developers)
