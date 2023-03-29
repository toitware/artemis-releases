# Artemis

Artemis is a fleet management system for ESP32 devices running the Toit platform.
It connects your devices to the cloud and makes it possible to seamlessly update
the firmware, containers, and configurations that run on your devices.

Artemis is the combination of an on-device service that communicates with a broker
in the cloud - and the developer tooling to help orchestrate the devices. It is
possible to host your own broker, so all your data and code remains under your
control.

## Installation

On your development machine, Artemis is a single command line tool (`artemis`).
You can download it from here:

- [Download Artemis for macOS](https://github.com/toitware/artemis-releases/releases/latest/download/artemis.dmg)
  (or as an [archive](https://github.com/toitware/artemis-releases/releases/latest/download/artemis-macos.zip))
- [Download Artemis for Windows](https://github.com/toitware/artemis-releases/releases/latest/download/artemis-windows.zip)
  (only as an archive)
- [Download Artemis for Linux](https://github.com/toitware/artemis-releases/releases/latest/download/artemis-linux.tar.gz)
  (only as an archive)

If you download an archive, you should unpack it and put the embedded `artemis` or `artemis.exe` binary
somewhere on your `PATH`. The same applies when you extract the `artemis` binary from the macOS `artemis.dmg`
file.

The Artemis command line tool is a standalone executable written in Toit. Use `artemis help` for usage help.
help.

## Signing up and logging in

All users must be authenticated. For OAuth-based authentication you can just
log into Artemis with `artemis auth artemis login`. During the first time, a
signup will be triggered automatically.

For email-based authentication sign up with:

``` sh
artemis auth artemis signup --email=myname@example.com --password=some_password
```

Then, after having confirmed the email address, log in with:

``` sh
artemis auth artemis login --email=myname@example.com --password=some_password
```

Usually, signing up by OAuth is more convenient, but email-based authentication is often useful
if you want to have multiple accounts. For example, with Google domains anything after
the "+" is discarded. So `email+additional@gmail.com` is an alias for `email@gmail.com`.

## Creating an organization

Every device must belong to an organization. You can create as many organizations as
you want (and there will eventually also be a way to remove them again). You can add an
organization using `artemis org create` like this:

``` sh
artemis org create "My Organization"
artemis org show
artemis org members list
```

The `artemis org show` command shows you your organization ID, which is a [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier).

Once you create a new organization it is automatically set as default. You can switch to a different organization with
`artemis org default YOUR-ORG-ID`, or by passing the organization id to the commands that need one.

You can add other users join your organization with `artemis org members add THEIR-USER-ID`. The
user you want to add can find THEIR-USER-ID with `artemis profile show`.

If you want to, you can also change the name in your profile with:

``` sh
artemis profile update --name "My full name"
```

---------------------

# Getting started

Once you've [downloaded](#installation) the command line tool (`artemis`),
[signed up](#signing-up-and-logging-in), and
[created an organization](#creating-an-organization),
you're ready to put Artemis on a device and manage it via the cloud.

## First steps

Artemis lets you describe the functionality and configuration of your devices
in version control friendly [specification files](#specification-files).
Let's start with the simplest possible specification file by putting the
following contents into a `device.json` file:

```
{
  "version": 1,
  "sdk-version": "v2.0.0-alpha.73",
  "artemis-version": "v0.4.3",
  "connections": [
    {
      "type": "wifi",
      "ssid": "YOUR WIFI NAME",
      "password": "YOUR WIFI PASSWORD"
    }
  ],
  "containers": {
  }
}
```

You can pick any name for the specification file (we went with `device.json`)
and it fully specifies what Artemis puts on the device when it is flashed.
Find more details on the content of the specification files [here](#specification-files).

To get your functionality onto your device, you flash a device with firmware
derived from the above specification by running:

``` sh
artemis device flash --port /dev/ttyUSB0 --specification device.json
```

This flashes the device over the USB serial port and puts both the Toit
platform and the Artemis service onto the device. Once flashed, you
can follow the behavior of your device by monitoring the serial port
using something like `jag monitor`
(included with [Jaguar](https://github.com/toitlang.org/jaguar)). It
shows something like this:

```
rst:0x5 (DEEPSLEEP_RESET),boot:0x13 (SPI_FAST_FLASH_BOOT)
configsip: 0, SPIWP:0xee
clk_drv:0x00,q_drv:0x00,d_drv:0x00,cs0_drv:0x00,hd_drv:0x00,wp_drv:0x00
mode:DIO, clock div:2
load:0x3fff0030,len:184
load:0x40078000,len:12700
ho 0 tail 12 room 4
load:0x40080400,len:2916
entry 0x400805c4
[toit] INFO: starting <v2.0.0-alpha.69>
[toit] INFO: using SPIRAM for heap metadata.
[artemis] INFO: starting {device: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}
[artemis.scheduler] INFO: job started {job: synchronize}
[artemis.synchronize] INFO: connecting
[wifi] DEBUG: connecting
[wifi] DEBUG: connected
[wifi] INFO: network address dynamically assigned through dhcp {ip: 192.168.86.31}
[wifi] INFO: dns server address dynamically assigned through dhcp {ip: [192.168.86.1]}
[network] INFO: opened
[artemis.synchronize] INFO: connected to network
[artemis.synchronize] INFO: connected to broker
[artemis.synchronize] INFO: synchronized
```

Once you see that the device succesfully connect to the cloud, you should
be ready to check its state:

``` sh
artemis device show
```

Great! With a little help from the Artemis service and developer tooling,
you have a cloud-managed device capable of running high-level code.

## Tinkering with your device

Artemis allows you to change and tinker with the current state of a device
without requiring a full firmware update. This makes it possible to change
the behavior of a device by adding new functionality (drivers or applications)
or by changing configurations.

Such incremental changes are great for development; especially as they are faster
to get onto the device and do not even require restarting the device.

### Controlling synchronization

It is very common to want to control how often a device connects to the cloud
and synchronizes.

Devices that connect frequently or all the time are easy
to interact with and manage, but they spend a lot of power on staying connected
all the time. The device specification in `device.json` does not specify
how often to connect, so Artemis assumes that you want an interactive device.

If you want to allow your device to not stay connected all the time, you can
give it a 'max-offline' setting. This tells the Artemis service that it is
okay to be offline for 5m, 1h30m, or 24h without necessarily connecting to the
Internet.

You can set this through:

``` sh
artemis device set-max-offline 1m19s
```

If you monitor the output of your device, you'll see that the device goes
to sleep between its cloud synchronizations.

You can go back to the original setting, where the device tries to
stay online all the time by giving it a 'max-offline' setting of 0s:

``` sh
artemis device set-max-offline 0s
```

### Installing code

Artemis makes it easy to install and uninstall new code on your devices.
The code that you install runs in containers, so they are isolated from
the rest of the system and can be started and stopped independently of
the other parts of the system.

To install new code on your device, you can install a new named container
based on a Toit source file:

``` sh
artemis device container install hello hello.toit
```

The container name `hello` does not have to match the source file
name `hello.toit` and you will use the container name to refer to
the installed container later. There can only be one container with
a given name on a device, so installing another one will replace
the original.

By default containers will run when installed and whenever the
device boots, but you can control this behavior by specifying the
triggers on the command line. If you *only* want to run when booting,
you can do:

``` sh
artemis device container install --trigger boot hello hello.toit
```

You can also get Artemis to run your containers on a schedule
by triggering them at a specified interval. As an example, you can
install the `hello` container and get it to run every 10s
like this:

```sh
artemis device container install --trigger interval:10s hello hello.toit
```

Any arguments you pass to `artemis device container install` after the
source file will be passed as string arguments to `main`. If you put
this in `args.toit`:

```
main args:
  print "arguments = $args"
```

and run:

``` sh
artemis device container install args args.toit foo bar
```

you should see `arguments = [foo, bar]` printed.

Finally, you can always uninstall a container again using:

``` sh
artemis device container uninstall hello
artemis device container uninstall args
```

## Updating the firmware over-the-air

If you want to update to a new version of the Toit SDK or benefit from the
latest Artemis release, you can do an over-the-air firmware update. Such
updates are pushed to the broker in a compressed form and picked up by the
device.

Similar to `artemis device flash`, the over-the-air update command also
takes a specification file, so the common workflow is to change your
specification files to reflect the state you want your devices in, and
then update them to that through:

``` sh
artemis device update --specification device.json
```

You can specify which device to update using a device-id flag (`-d`), but most
of the time you just use the default ID that was either set
during flashing, or that can be set with `artemis device default`.

---------------------

# Details

This sections shows more details about some the commands and file formats.

## Device commands

### `artemis device flash`

The flash command converts your specification file into a binary firmware and
flashes it onto your device using a bundled version of
[`esptool`](https://github.com/espressif/esptool).

Unless you are on Linux you will probably need to change the `/dev/ttyUSB0` to your
setup.  Sometimes the name is `/dev/ttyACM0`, depending on which USB-to-serial driver
your computer is using.

On some ESP32 devices, you need to press a button to flash it over USB.

If the flashing doesn't work you might still end up with a provisioned identity, that
isn't used. We will improve this situation, but for now don't worry about it.

To access `/dev/ttyUSB0` on Linux you probably need to be a member
of some group, normally either `uucp` or `dialout`.  To see which groups you are
a member of and which group owns the device, plug in an ESP32 to the USB port
and try:

``` sh
groups
ls -g /dev/ttyUSB0
```

If you lack a group membership, you can add it with

``` sh
sudo usermod -aG dialout $USER
```

You usually have to log out and log back in for this to take effect.

### `artemis device show`

You can always see the status of your device by doing `artemis device show`. It shows
useful information about a device, including its state and recent events:

```
% artemis device show -d xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --max-events=6
Device ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Organization ID: yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy

Firmware state as reported by the device:
  apps:
    cellular:
      id: bad371bf-af6d-5188-0da4-ac3a3b98d3a2
      triggers:
        boot: 1
      background: 1
  firmware: eyNVAlUPZGV2aWNlLXNwZWNpZmljWyRVI0kB1nsj...QXu7oV/CJX94Q3P0Ae/Vau/XsWL7JJl1iWSw0w==
  connections: [{type: cellular, config: {cellular.apn: soracom.io, cellular.uart.rx: 23, cellular.uart.tx: 5, cellular.uart.cts: 18, cellular.uart.rts: 19, cellular.log.level: 1}}, {ssid: ..., type: wifi, password: ...}]
  max-offline: 300
  sdk-version: v2.0.0-alpha.69

Goal is the same as the reported firmware state.

Events:
  15:17:12.981 get-goal
  15:12:05.228 get-goal
  15:01:43.273 get-goal
  15:01:41.943 update-state
  15:01:28.073 update-state
  15:00:34.871 get-goal
```

You can use the events as a primitive health monitoring facility and see when
the device synchronize from the cloud (`get-goal`) and to the cloud (`update-state`).

## Specification files

You can find an example specification file in [examples/specification.json](examples/specification.json).
It is in JSON format and looks similar to this:

```
{
  "version": 1,
  "sdk-version": "v2.0.0-alpha.73",
  "artemis-version": "v0.4.3",
  "max-offline": "0s",
  "connections": [
    {
      "type": "wifi",
      "ssid": "YOUR SSID",
      "password": "YOUR WIFI PW"
    }
  ],
  "containers": {
    "hello": {
      "entrypoint": "hello.toit"
    },
    "solar": {
      "entrypoint": "examples/solar_example.toit",
      "git": "https://github.com/toitware/toit-solar-position.git",
      "branch": "v0.0.3"
    }
  }
}
```

The three version entries are for the specification format (always `1` for now) and the
SDK and Artemis versions. Be aware that not all combinations of those are supported and
use `artemis sdk list` to see the valid combinations.

The `max-offline` entry is optional and defaults to 0s. Use it to control for how
long your device is allowed to stay offline.

The `connections` section contains a prioritized list of ways to connect to the
Internet. You can have multiple `wifi` entries and Artemis will attempt to
connect to them in the specified order.

It is also possible to have `cellular` entries in `connections`, but for that to
work you'll need to have a cellular driver installed as one of your containers.
You can find a few drivers in the [cellular package](https://github.com/toitware/cellular).

The `containers` section contains named entries for the containers
you want on your device. The containers that are built from source
code have an `entrypoint` that refers to the file that has the
`main` method. You can optionally pull the source code directly
from git using `git` and `branch`.

If your container is a driver or provides services for other
containers, you probably want to start it on boot and let it
run until no other container runs. For that to work, you can
make it a background container that is automatically terminated
when the device goes to sleep like this:

```
"containers": {
  "cellular": {
    "entrypoint": "src/modules/sequans/monarch.toit",
    "git": "https://github.com/toitware/cellular.git",
    "branch": "v2.0.1",
    "background": true,
    "critical": true
  }
}
```

The `critical` flag makes the container run continuously. If you want your container
to run periodically, you can specify interval triggers in the `containers` section
like this:

```
"containers": {
  "measure": {
    "entrypoint": "measure.toit",
    "triggers": [ { "interval": "20s" } ]
  }
}
```
