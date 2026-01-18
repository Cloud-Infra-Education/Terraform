#!/bin/bash

terraform apply -auto-approve
./copy_ipsec_files.sh
