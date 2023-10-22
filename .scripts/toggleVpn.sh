#!/bin/sh

send_notification() {
	notify-send "VPN is On"
}

generate_config_file() {
	local host=$(pass show vpn/folder | grep -oP '(?<=host: ).*')
	local port=$(pass show vpn/folder | grep -oP '(?<=port: ).*')
	local username=$(pass show vpn/folder | grep -oP '(?<=user: ).*')
	local password=$(pass show vpn/folder | grep -oP '(?<=password: ).*')
	local trusted_cert=$(pass show vpn/folder | grep -oP '(?<=cert: ).*')

	cat <<EOF >/tmp/config_file.conf
host=$host
port=$port
username=$username
password=$password
trusted-cert=$trusted_cert
EOF
}

if pgrep openfortivpn >/dev/null; then
	pkexec pkill openfortivpn
	rm /tmp/config_file.conf
else
	generate_config_file
	pkexec openfortivpn --config /tmp/config_file.conf
fi
