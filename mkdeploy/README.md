# Run Machinekit package deploy and distribution in Docker

The `run.sh` script wraps common Docker functions.  It create the repo
directory in `~/aptrepo`.

Build the container image:

    ./run.sh build

Initialize the `~/aptrepo` directory; must be done once before run:

	./run.sh init

Run the container; also configures the container to start at boot
time:

    ./run.sh run

Stop the container:

	./run.sh stop

Restart the container:

	./run.sh restart

Destroy the container:

	./run.sh destroy

Start an interactive shell in the running container:

	./run.sh shell

Run a command in the running container:

	./run.sh shell ps -efww

Connect through ssh:

    ssh aptrepo@localhost -p2222

# SSH `authorized_keys`

Add ssh pubkeys to `~/aptrepo/.ssh/authorized_keys`.

# APT repo initialization

The APT repo will be initialized in `~/aptrepo/repo`.

If GPG signing keys already exist, create the directory
`~/aptrepo/gnupg` and place the signing keys there.  Otherwise, new
keys will be generated at `./run.sh init`.  Do not create a passphrase
or signatures cannot run automatically.

Edit `get-ppa.sh`:

- Update `CODENAMES`
- Update `UPDATES[<codename>]` for each distro; the words in these
  strings refer to `reprepro` update configurations in
  `reprepro-templates/tmpl.updates-<word>`
- Update the `reprepro` configurations in the `reprepro-templates`
  directory
  - `tmpl.updates-*` configure `reprepro` to mirror other APT
    repositories
  - `tmpl.distributions` configures `reprepro` to build the
    destination APT repository

# APT repo management

The repo is initialized when the container is initialied, and the
container will periodically run updates.  Mostly there should be no
maintenance.

Some utilities are available for dumping the package signing key,
listing packages, etc.  Run `./run.sh repo` for usage.  For example,
to list packages in the `wheezy` distro:

	./run.sh repo -c wheezy -l

