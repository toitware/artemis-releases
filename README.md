# Artemis

Artemis is a fleet management system for Toit devices. It connects your devices to the cloud and makes it possible
to seamlessly update the firmware, containers, and configurations that run on your devices.

## Installation

Artemis consists of a single executable. You can download it from here:

- [Download Artemis for macOS](https://github.com/toitware/artemis-releases/releases/latest/download/artemis.dmg)
  (or as an [archive](https://github.com/toitware/artemis-releases/releases/latest/download/artemis-macos.zip))
- [Download Artemis for Windows](https://github.com/toitware/artemis-releases/releases/latest/download/artemis-windows.zip)
  (only as an archive)
- [Download Artemis for Linux](https://github.com/toitware/artemis-releases/releases/latest/download/artemis-linux.tar.gz)
  (only as an archive)

If you download an archive, you should unpack it and put the embedded `artemis` or `artemis.exe` binary
somewhere on your `PATH`. The same applies when you extract the `artemis` binary from the macOS `artemis.dmg` file.

## Authentication

All users must be authenticated.

### Signing up

For OAuth-based authentication you can just log into Artemis with `artemis auth artemis login`.
During the first time, a signup will be triggered automatically.

For email-based authentication sign up with
`artemis auth artemis signup --email=foo@bar.com --password=some_password`.

Then, after having confirmed the email address, log in with
`artemis auth artemis login --email=foo@bar.com --password=some_password`.

Usually, signing up by OAuth is more convenient, but email-based authentication is often useful
if you want to have multiple accounts. For example, with Google domains anything after
the "+" is discarded. So `email+additional@gmail.com` is an alias for `email@gmail.com`.

## Organizations

Every device must be inside an organization. You can create as many organizations as 
you want (and there will eventually also be a way to remove them again). You can an
organization using `artemis org create` like this:

```
artemis org create "my new org"
artemis org show
artemis org members list
```

Once you create a new organization it is automatically set as default. You can switch to a different org with
`artemis org default YOUR-ORG-ID`, or by passing the organization id to the commands that need one.

You can add other users join your organization with `artemis org members add THEIR-USER-ID`. The
user you want to add can find THEIR-USER-ID with `artemis profile show`.

If you want to, you can also change the name in your profile with 
`artemis profile update --name "My full name"`.

---------------------

## Device commands

The most important commands to deal with devices are `artemis device flash` 
and `artemis device update`. You can probably manage a whole fleet of devices with
just those two...

Both take a specification file as input (see below) that lists which versions of Toit 
SDK and the Artemis service to run on the device, how the device connects to the Internet, 
and which containers with code.

### Flashing the device initially

Plug an ESP32 into your serial port and run the following command:

``` sh
artemis device flash --specification YOUR-SPECIFICATION.json --port /dev/ttyUSB0
```

Unless you are on Linux you will probably need to change the `/dev/ttyUSB0` to your
setup.

Note that the specification contains the software version that needs to be used,
so Artemis will download the correct SDK in the background.

The `artemis device flash` command automatically sets the flashed device as the default, so that
other device commands don't need to pass in a device flag.

If the flashing doesn't work you might still end up with a provisioned identity, that
isn't used. We will improve this situation, but for now don't worry about it.

You can use the usual monitoring tools (like `jag monitor`) to watch the output of the
device.

### Updating the firmware over-the-air

Similar to 'flash' the update command also takes a specification file. It can take a
device-id flag (`-d`), but most of the time you just use the default ID that was either set
during flashing, or that can be set with toit device default.

``` ah
artemis device update --specification YOUR-SPECIFICATION.json`
```

## Specification files

An example specification file is located in [examples/specification.json](examples/specification.json).

It looks similar to this:
```
{
  "version": 1,
  "sdk-version": "v2.0.0-alpha.69",
  "artemis-version": "v0.4.0",
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

Most of these should be self-explanatory, but be aware that not all sdk-versions and Artemis-versions are supported.

Use `artemis sdk list` to see the valid combinations.

### Showing the status of a device

You can always see the status of your device by doing `artemis device show`. It shows
useful information about a device, including its state and recent events:

```
% artemis device show -d 5a52f07f-c2fb-54b9-b611-21e8fcec678b --max-events=6
Device ID: 5a52f07f-c2fb-54b9-b611-21e8fcec678b
Organization ID: a2f4df63-f9ed-4452-be76-4d86136d23f9 (Holtshøjen)

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

---------------------

# Getting started

## First steps

Start with the simplest possible specification file by putting the following
contents into a `device.json` file: 

```
{
  "version": 1,
  "sdk-version": "v2.0.0-alpha.69",
  "artemis-version": "v0.4.0",
  "max-offline": "0s",
  "connections": [
    {
      "type": "wifi",
      "ssid": "YOUR SSID",
      "password": "YOUR WIFI PW"
    }
  ],
  "containers": {
  }
}

You can flash a device with firmware derived from the above specification
by running:

``` sh
artemis device flash --port /dev/ttyUSB0 --specification device.json
```

This will flash the device over the serial port and put both the Toit 
platform and the Artemis service onto the device. You can see what it
does if you monitor the serial port using something like `jag monitor` 
(included with [Jaguar](https://github.com/toitlang.org/jaguar)). It
shows something like this:

```
...
```

## Incremental changes

There are some commands in `artemis device` that only change the current configuration of
a device and do not require a full firmware update.

Such incremental changes are a good way for development; especially as they are faster
to get onto the device.

The following commands of `artemis device` are incremental:

1. `container install`: installs a new container
2. `container uninstall`: uninstalls the container again
3. `set-max-offline`: sets the max offline to the given time (in seconds).

As an example, you can install the `hello` container and get it to run every 10s like this:

```sh
artemis device container install --trigger interval:10s hello hello.toit
```
