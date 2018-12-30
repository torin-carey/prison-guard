#!/bin/bash

echo "Deleting routes"
set -x
ip route del default table prisonguard dev $dev
set +x
