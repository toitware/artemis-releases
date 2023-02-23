# Artemis

Artemis is a fleet management system for Toit devices. It connects your devices to the cloud and makes it possible
to seamlessly update the firmware, containers, and configurations that run on your devices.

## Installation

Artemis consists of a single executable. Download the corresponding tar.gz or .zip file and use the executable that is in it.

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
`artemis org default org-id`, or by passing the organization id to the commands that need one.

You can add other users join your organization with `artemis org members add <user-id>`.

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
`artemis device flash --specification <some-specification.json> --port /dev/ttyUSB0`

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

`artemis device update --specification <some-specification.json>`

Note: any `[message decoder: wrong tison marker ...]` message is benign and can be ignored.

## Specification file
An example specification file is located in [examples/specification.json](examples/specification.json).

It looks similar to this:
```
{
  "version": 1,
  "sdk-version": "v2.0.0-alpha.54",
  "artemis-version": "v0.1.0",
  "max-offline": "10s",
  "connections": [
    {
      "type": "wifi",
      "ssid": "YOUR SSID",
      "password": "YOUR WIFI PW"
    }
  ],
  "apps": {
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

Change the apps (for example a different entry point, or a different solar version).

Change the sdk-version and Artemis-version, but make sure the combination is supported (use
`artemis sdk list` to get all possible combinations).

Run `artemis update --specification <specification-file>` to update the device.

The device should find the new configuration and automatically update.

## Transient changes
The transient feature is still under development and might change.

Commands that are in `artemis device transient` only change the current configuration of
a device, but are not persistent. A reboot of the device will return to the last
firmware state.

As such, transient changes are a good way for development; especially as they are faster
to get onto the device.

There are 3 commands in the `artemis transient` section:

1. `install`: installs a new application
2. `uninstall`: removes the application again
3. `set-max-offline`: sets the max offline to the given time (in seconds).

Note that install and uninstall currently don't have any effect on the applications that
are in the flash. It is therefore not possible to temporarily disable or update an application
that has been installed together with the firmware.
