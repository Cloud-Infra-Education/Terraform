#!/bin/bash

cp generated/ipsec.conf /etc/ipsec.conf
cp generated/ipsec.secrets /etc/ipsec.secrets
ipsec restart

