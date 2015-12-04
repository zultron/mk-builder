#! /usr/bin/python

import sys
import subprocess
import ConfigParser
import os
import traceback
import threading
import time

# wait 30 seconds for error notifiers to complete before hard-exiting
SCRIPT_TIMEOUT = 30

CONFIG_PATH = "/conf/process-incoming.cfg"

REPREPRO_CMD = [
        'reprepro',
        '--waitforlock', '1000',
        'processincoming', os.environ['RULENAME'],
    ]

def reprepro(changes):
    reprepro = subprocess.Popen(REPREPRO_CMD + [changes], stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)
    output, _ = reprepro.communicate()
    print output
    if not reprepro.returncode:
        return

    for dest in config.sections():
        if dest not in handlers:
            print "unknown destination type '%s', skipping" % dest
            continue
        print 'process-incoming.py: Sending error to', dest
        thread = threading.Thread(target=handlers[dest], args=(output,))
        thread.daemon = True
        thread.start()


handlers = {}

def handler(dest):
    def f(func):
        if dest in handlers:
            raise Exception("handler for '%s' defined more than once" % dest)
        handlers[dest] = func
        return func
    return f


@handler('irc')
def handle_irc(msg):
    import irc.client

    server = config.get('irc', 'server')
    port = config.getint('irc', 'port')
    nick = config.get('irc', 'nick')
    channel = config.get('irc', 'channel')

    if not irc.client.is_channel(channel):
        raise Exception("Invalid IRC channel '%s'" % channel)

    class Sender(irc.client.SimpleIRCClient):
        done = False

        def on_welcome(self, conn, evt):
            conn.join(channel)

        def on_join(self, conn, evt):
            for line in msg.split('\n'):
                conn.privmsg(channel, line)
            conn.quit()
            self.done = True

        def on_disconnect(self, conn, evt):
            self.done = True

        def run(self):
            self.connect(server, port, nick)
            while not self.done:
                self.ircobj.process_once(0.2)

    Sender().run()


def main(args):
    global config
    config = ConfigParser.SafeConfigParser()
    config.read(CONFIG_PATH)

    if not args:
        raise Exception('no changes files specified')
    if len(args) > 1:
        raise Exception('only one changes file may be specified')

    print 'process-incoming.py: Starting reprepro'

    reprepro(args[0])

    # wait SCRIPT_TIMEOUT seconds for threads to finish
    start = time.time()
    while (time.time() - start) < SCRIPT_TIMEOUT:
        threads = threading.enumerate()[1:]
        if not threads:
            break
        threads[0].join(start + SCRIPT_TIMEOUT - time.time())

    print 'process-incoming.py: Finished'


if __name__ == "__main__":
    main(sys.argv[1:])
