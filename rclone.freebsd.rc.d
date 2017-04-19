#!/bin/sh

# PROVIDE: rclone
# REQUIRE: NETWORKING SERVERS DAEMON ldconfig resolv
# KEYWORD: shutdown

# rclone_config (string):   path to rclone.conf
# rclone_remote (string):   remote to mount
# rclone_mount (string):    mount point for remote
# rclone_log_file (string): path to logfile
# rclone_pidfile (string):  path to pid file

. /etc/rc.subr

name="rclone"
rcvar="${name}_enable"

load_rc_config "$name"
: ${rclone_log_file:=/var/log/rclone.log}
: ${rclone_pidfile:=/var/run/rclone.pid}
: ${rclone_config:=/usr/local/etc/rclone.conf}

if [ "$rclone_remote" = "" ]
then
    echo "rclone_remote required in rc.conf"
    exit 1
fi

if [ "$rclone_mount" = "" ]
then
    echo "rclone_mount required in rc.conf"
    exit 1
fi

pidfile=$rclone_pidfile
command="/usr/local/bin/rclone"
command_args="--log-file $rclone_log_file --config $rclone_config mount $rclone_remote $rclone_mount"
start_cmd="rclone_start"
stop_cmd="rclone_stop"

rclone_start() {
    /usr/sbin/daemon -f -p $pidfile $command $rc_flags $command_args
}

rclone_stop() {
    if [ $rc_pid ]; then
        echo "stopping $name."
        /sbin/umount $rclone_mount
        kill $rc_pid
        wait_for_pids $rc_pid
    else
        echo "$name is not running."
    fi
}

run_rc_command "$1"
