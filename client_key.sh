#!/bin/bash

sudo apt install -y strongswan

if [[ ! -f "root.ca.crt" ]]; then
	echo "root.ca.crt doesn't exist. Download this file or send message for admin."
	exit 1
fi

sudo cp root.ca.crt /etc/ipsec.d/cacerts/

read -p "Enter P12 key name: " KEY_NAME

if [[ ! -f $KEY_NAME ]]; then
	echo "Key desn't exist. Please, enter right keyname."
	exit 1
fi

sudo cp $KEY_NAME /etc/ipsec.d/private/

read -p "Enter P12 key password: " KEY_PASSWORD
read -p "Enter username: " USERNAME

echo -e "\
config setup\n\
conn ztractor-vpn\n\
        keyexchange=ikev2\n\
        ike=aes128-sha256-modp2048\n\
        esp=aes128-sha1\n\
        leftsourceip=%modeconfig\n\
        leftcert=$KEY_NAME\n\
        leftfirewall=yes\n\
        leftsendcert=always\n\
        leftid=$USERNAME\n\
        right=ec2-3-139-10-192.us-east-2.compute.amazonaws.com\n\
        rightsubnet=0.0.0.0/0\n\
        auto=add" | sudo tee /etc/ipsec.conf > /dev/null

echo ": P12 $KEY_NAME \"$KEY_PASSWORD\"" | sudo tee /etc/ipsec.secrets > /dev/null

sudo systemctl enable strongswan
sudo systemctl restart strongswan