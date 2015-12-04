# Reprepro Incoming-Enabled Docker Image

[reprepro](https://mirrorer.alioth.debian.org) is a Debian package repository management tool. This Docker image uses `inoticoming` to automatically import packages into the repository, and can send notification messages on import error.

## Volumes

-   `/conf`: place your reprepro config files here.
-   `/data`: input and output for reprepro.

## Reprepro Configuration

There are many guides on how to configure reprepro, and so guidance is not included here. The only default configuration this image provides is by creating `/conf/options` if `/conf` is empty, pointing reprepro at /data. Add any other global flags you need to that file.

It is recommended that you set `TempDir` to `/data/tmp` in `/conf/incoming`.

The following environment variables can be overridden to alter reprepro's behavior:

-   `RULENAME`: default "incoming" - which rule to run for processincoming.

## Reprepro Error Notification

To enable, copy the example file `process-incoming.cfg` in `/conf` and customize it.

### IRC

This is the only notification method currently supported. It does not use a persistent bot, instead connecting to IRC for every error message. Configure it in the `[irc]` section of the config file.

## GnuPG Keyring Configuration

You can supply gpg public and private keys by placing them at `/conf/reprepro_pub.gpg` and `/conf/reprepro_sec.gpg` respectively. If the gpg config directory doesn't exist, and these do, they will be imported into reprepro's keyring. The files may be of any format `gpg --import` accepts.

The following environment variables can be overridden to configure the gpg keyring:

- `GNUPGHOME`: (default "/data/.gnupg") sets where GnuPG stores its configuration and keyrings
- `REPREPRO_PUBRING`: (default "/conf/reprepro_pub.gpg") the public keyring to import
- `REPREPRO_SECRING`: (default "/conf/reprepro_sec.gpg") the secret keyring to import

It is recommended that `reprepro_sec.gpg` not be world-readable.

Alternatively, you can manage the configuration specified by GNUPGPHOME directly, as long as it is readable by the reprepro user.

It is also recommended that you configure gpg to use stronger hash algorithms than the default when signing. Edit `$GNUPGHOME/gpg.conf` and add the line

    personal-digest-preferences SHA256

## Incoming

`/data/incoming` is watched for `.changes` files, and `reprepro processincoming` is run on each one that appears.

## The Repository

`/data/archive` is where the actual repository is built. You will want to map it to the host filesystem to be served directly via a web server, which is much more efficient than the standard reverse-proxy setup.

## Running Reprepro Commands

A wrapper for reprepro is in /usr/local/bin, to run reprepro as the appropriate user. You can call it via `docker exec [containername] reprepro [command]`.
