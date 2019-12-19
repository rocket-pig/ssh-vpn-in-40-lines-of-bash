# ssh-vpn-in-40-lines-of-bash
the holy grail of tiny vpns, requires almost nothing (bash,ssh,basic network tools found on every *nix)


I don't remember where I found this. A few changes were added by me but its mostly net copypasta from someone more familiar with pppd than I.  I spent a long time dicking around with tun2socks / badvpn / openvpn / sshuttle / an endless litany of trippy poor-man's vpns.  This takes the cake in 42 lines.

##Usage:
make sure you have an internet connection, a remote sshd server with passwordless login set up via ~/.ssh/config.

run `sudo ./tunnel.sh`. that's literally it. Ctrl-C is hooked and will gracefully disconnect.

...When you do:
it should connect, forward local port 53 to remote side (DNS proxy), and set up a new ppp interface on local side at 10.0.0.1.  You can directly address your remote machine at 10.0.0.2.  

Your remote machine must be set up to forward packets.  If its a linux host, this'll do it:
(Note that 'ens3' should be name of your server's public-facing network adapter)

`echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward`
`iptables -F FORWARD`
`iptables -A FORWARD -j ACCEPT`
`iptables -A POSTROUTING -t nat -o ens3 -j MASQUERADE`
`iptables -A POSTROUTING -t nat -o ppp+ -j MASQUERADE`

And that's it! The script also takes care of changing the default route, so all internet-related apps on local system will "just work".  No http/ssl/socks (4? 5? passwords? no?) /openvpn 12-page keys or weird handshakes to figure out. It's a 'normal' internet connection and you can get on with other shit, cheers

All thanks go to old internet posts, I just wanted to immortalize it further <3
