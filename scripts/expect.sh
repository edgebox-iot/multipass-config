#!/usr/bin/expect

# This is a wrapper script for running an ssh command with a password passed as argument

set timeout 20

set cmd [lrange $argv 1 end]
set password [lindex $argv 0]

eval spawn $cmd
expect "password:"
send "$password\r";
interact