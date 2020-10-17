#!/usr/bin/expect -d
set timeout -1
set username sftp
set password c83eDteUDT
set server localhost
set mountpoint /tmp/fs

# connect to server
send_user "connecting to $server\n"
spawn -ignore HUP /usr/bin/sshfs -p 2222 $username@$server:/ $mountpoint
#login handles cases:
#   login with keys (no user/pass)
#   user/pass
#   login with keys (first time verification)
#   user/pass (first time verification)
expect {
    ")?" {
        send "yes\n"
        expect {
            "word:" {
                send "$password\n"
                expect {
                    "\n" { }
                }
            }
            "\n" { }
        }
    }
    "word:" {
        send "$password\n"
        expect {
            "\n" { }
        }
    }
}