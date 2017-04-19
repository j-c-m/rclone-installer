#!/bin/sh


S=$(uname -s | tr '[:upper:]' '[:lower:]')
M=$(uname -m)

case $M in
    x86_64) M="amd64"
        ;;
    amd64)
        ;;
    i386) M="386"
        ;;
     arm)
        ;;
esac

URL="http://downloads.rclone.org/rclone-current-${S}-${M}.zip"
TMPDIR=`mktemp -d`

if type fetch; then
    fetch -o $TMPDIR/rclone.zip $URL
elif type wget; then
    wget -O $TMPDIR/rclone.zip $URL
elif type curl; then
    curl -o $TMPDIR/rclone.zip $URL
else
    echo "Unable to fetch $URL."
    exit 1
fi

case $S in
    freebsd)
        tar -xf $TMPDIR/rclone.zip -C $TMPDIR --strip-components 1
        GROUP="wheel"
        ;;
    linux)
        unzip -j $TMPDIR/rclone.zip -d $TMPDIR
        GROUP="root"
        ;;
esac

gzip $TMPDIR/rclone.1

mkdir -p /usr/local/bin
mkdir -p /usr/loal/man/man1
install -v -m 755 -o root -g $GROUP $TMPDIR/rclone /usr/local/bin
install -v -m 644 -o root -g $GROUP $TMPDIR/rclone.1.gz /usr/local/man/man1

rm -r $TMPDIR
