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

Not yet implemented
