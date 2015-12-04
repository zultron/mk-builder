#! /bin/sh

if [ -z "$(ls -A /data)" ]; then
    echo "setting up /data"
    mkdir /data/db /data/archive /data/logs /data/incoming /data/tmp
    chown -R reprepro /data
fi

if [ -z "$(ls -A /conf)" ]; then
    echo "creating /conf/options"
    cat << EOF > /conf/options
basedir /data
confdir /conf
outdir /data/archive
EOF
fi

if [ ! -d "$GNUPGHOME" ]; then
    [ -f "$REPREPRO_PUBRING" ] && gosu reprepro gpg --import "$REPREPRO_PUBRING"
    [ -f "$REPREPRO_SECRING" ] && gosu reprepro gpg --import "$REPREPRO_SECRING"
fi

exec inoticoming --foreground --initialsearch /data/incoming --suffix .changes /process-incoming.py {} \;
