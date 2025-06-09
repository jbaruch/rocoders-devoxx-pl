#!/bin/bash

# Discover Shelly Color Bulbs on local network using mDNS
echo "Discovering Shelly devices..."
dns-sd -B _http._tcp local. | grep shellycolorbulb