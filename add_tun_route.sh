#!/bin/bash

echo "Adding routes"
set -x
ip route add default table prisonguard dev $dev
set +x
