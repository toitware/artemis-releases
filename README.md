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
For oauth-based authentication you can just log into Artemis with `artemis auth artemis login`.
During the first time, a signup will be triggered automatically.

For email-based authentication sign up with
`artemis auth artemis signup --email=foo@bar.com --password=some_password`.

Then, after having confirmed the email address, log in with
`artemis auth artemis login --email=foo@bar.com --password=some_password`.

Usually, signing up by oauth is more convenient, but email-based authentication is often useful
if you want to have multiple accounts. For example, with Google domains anything after
the "+" is discarded. So `email+additional@gmail.com` is an alias for `email@gmail.com`.

## Organization
Every device must be inside an organization.

You can create as many organizations as you want (and there will eventually also be a way to remove them again).

```
artemis org create "my new org"
artemis org show
artemis org members list
```

Once you create a new organization it is automatically set as default. You can switch to a different org with
`artemis org default YOUR-ORG-ID`, or by passing the organization id to the commands that need one.

You can add other users join your organization with `artemis org members add YOUR-USER-ID`.

The user-id can be found with `artemis profile show`.

If you want to, you can also change the name in your profile with
  `artemis profile update --name "My full name"`.

## Device
The most important commands to deal with devices are
`artemis device flash` and `artemis device update`.

You can probably manage a whole fleet of devices just with those two...

Both take a specification file as input (see below).

### Flash
Plug in an esp32 and run the following command:
`artemis device flash --specification YOUR-SPECIFICATION.json --port /dev/ttyUSB0`

Unless you are on Linux you will probably need to change the `/dev/ttyUSB0` to your
setup.

Note that the specification contains the software version that needs to be used,
so Artemis will download the correct SDK in the background.

The flash command automatically sets the flashed device as the default, so that
other device commands don't need to pass in a device flag.

If the flashing doesn't work you might still end up with a provisioned identity, that
isn't used. We will improve this situation, but for now don't worry about it.

You can use the usual monitoring tools (like `jag monitor`) to watch the output of the
device.

### Update
Similar to 'flash' the update command also takes a specification file. It can take a
device-id flag, but most of the time you just use the default ID that was either set
during flashing, or that can be set with toit device default.

`artemis device update --specification YOUR-SPECIFICATION.json`

## Specification file
An example specification file is located in [examples/specification.json](examples/specification.json).

It looks similar to this:
```
{
  "version": 1,
  "sdk-version": "v2.0.0-alpha.64",
  "artemis-version": "v0.2.3",
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

## First steps
Create a hello.toit and put it next to the specification file.

Flash the device with the specification.

Change the containers (for example a different entry point, or a different solar version).

Change the sdk-version and Artemis-version, but make sure the combination is supported (use
`artemis sdk list` to get all possible combinations).

Run `artemis device update --specification YOUR-SPECIFICATION.json` to update the device.

The device should find the new configuration and automatically update.

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
