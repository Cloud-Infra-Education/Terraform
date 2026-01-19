#!/bin/bash

terraform apply -auto-approve
cp generated/ipsec.conf /etc/ipsec.conf
cp generated/ipsec.secrets /etc/ipsec.secrets
sysctl -w net.ipv4.conf.all.disable_policy=1
ipsec restart

