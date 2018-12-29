#!/bin/bash

echo "Deleting routes"
set -x
ip route del 0.0.0.0/1 table prisonguard dev $dev
ip route del 128.0.0.0/1 table prisonguard dev $dev
set +x
