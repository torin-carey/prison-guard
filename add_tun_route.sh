#!/bin/bash

echo "Adding routes"
set -x
ip route add 0.0.0.0/1 table prisonguard dev $dev
ip route add 128.0.0.0/1 table prisonguard dev $dev
set +x
