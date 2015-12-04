#! /bin/sh

umask 002
# hack to fix bad interaction between docker tty bug #11462 and gpgsm
exec | cat
exec gosu reprepro /usr/bin/reprepro "$@"
