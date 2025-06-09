#!/bin/bash

# Discover Shelly Color Bulbs on local network using mDNS
echo "Discovering Shelly devices..."
echo "Local DNS Name                    IP Address"
echo "----------------------------------------"

# Set a timeout for the entire discovery process
timeout 15 dns-sd -B _http._tcp local. > /tmp/shelly_discovery.txt 2>&1 &
discovery_pid=$!

# Wait a bit for discovery to populate
sleep 5

# Kill the discovery process
kill $discovery_pid 2>/dev/null

# Process the results
if [ -f /tmp/shelly_discovery.txt ]; then
    grep shellycolorbulb /tmp/shelly_discovery.txt | while read line; do
        # Extract the service name from the discovery output (last column)
        service_name=$(echo "$line" | awk '{print $NF}')
        
        if [ -n "$service_name" ]; then
            echo "Found Shelly device: $service_name"
            
            # Resolve the service to get IP address and port
            timeout 5 dns-sd -L "$service_name" _http._tcp local. > /tmp/resolve_$$.txt 2>&1 &
            resolve_pid=$!
            sleep 3
            kill $resolve_pid 2>/dev/null
            
            if [ -f /tmp/resolve_$$.txt ]; then
                # Look for the hostname in the resolve output (remove ANSI escape codes)
                hostname=$(grep "can be reached at" /tmp/resolve_$$.txt | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $7}' | sed 's/:.*$//' | head -1)
                
                if [ -n "$hostname" ]; then
                    # Get IP address using multiple methods
                    ip_address=""
                    
                    # Try ping first (most reliable for .local domains)
                    ip_address=$(timeout 3 ping -c 1 "$hostname" 2>/dev/null | grep "PING" | awk '{print $3}' | sed 's/[():]//g' | head -1)
                    
                    # If that fails, try nslookup
                    if [ -z "$ip_address" ]; then
                        ip_address=$(timeout 3 nslookup "$hostname" 2>/dev/null | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -1)
                    fi
                    
                    # If that fails, try dig
                    if [ -z "$ip_address" ]; then
                        ip_address=$(timeout 3 dig +short "$hostname" 2>/dev/null | head -1)
                    fi
                    
                    # If that fails, try host
                    if [ -z "$ip_address" ]; then
                        ip_address=$(timeout 3 host "$hostname" 2>/dev/null | awk '{print $NF}' | head -1)
                    fi
                    
                    # Output formatted result
                    if [ -n "$ip_address" ]; then
                        printf "%-30s %s\n" "$hostname" "$ip_address"
                    else
                        printf "%-30s %s\n" "$hostname" "Unable to resolve IP"
                    fi
                fi
                
                rm -f /tmp/resolve_$$.txt
            fi
        fi
    done
    
    # Clean up
    rm -f /tmp/shelly_discovery.txt
else
    echo "No discovery results found"
fi

echo "Discovery complete."