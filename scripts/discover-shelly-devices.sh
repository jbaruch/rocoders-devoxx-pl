#!/bin/bash

# Discover Shelly Color Bulbs on local network using mDNS

# Initialize variables
found_devices=0
temp_file="/tmp/shelly_discovery_$$"

echo "🔍 Discovering Shelly devices on local network..."
echo

# Set a timeout for the entire discovery process
timeout 15 dns-sd -B _http._tcp local. > "$temp_file" 2>/dev/null &
discovery_pid=$!

# Wait for discovery to populate
sleep 5

# Kill the discovery process
kill $discovery_pid 2>/dev/null
wait $discovery_pid 2>/dev/null

# Process the results
if [ -f "$temp_file" ]; then
    # Create array to store devices
    declare -a devices
    
    while IFS= read -r line; do
        # Extract the service name from the discovery output (last column)
        service_name=$(echo "$line" | awk '{print $NF}')
        
        if [ -n "$service_name" ]; then
            # Resolve the service to get IP address and port
            resolve_file="/tmp/resolve_$$"
            timeout 5 dns-sd -L "$service_name" _http._tcp local. > "$resolve_file" 2>/dev/null &
            resolve_pid=$!
            sleep 3
            kill $resolve_pid 2>/dev/null
            wait $resolve_pid 2>/dev/null
            
            if [ -f "$resolve_file" ]; then
                # Look for the hostname in the resolve output (remove ANSI escape codes)
                hostname=$(grep "can be reached at" "$resolve_file" | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $7}' | sed 's/:.*$//' | head -1)
                
                if [ -n "$hostname" ]; then
                    # Get IP address using ping (most reliable for .local domains)
                    ip_address=$(timeout 3 ping -c 1 "$hostname" 2>/dev/null | grep "PING" | awk '{print $3}' | sed 's/[():]//g' | head -1)
                    
                    # If ping fails, try dig
                    if [ -z "$ip_address" ]; then
                        ip_address=$(timeout 3 dig +short "$hostname" 2>/dev/null | head -1)
                    fi
                    
                    # Store device info
                    if [ -n "$ip_address" ]; then
                        devices+=("$hostname|$ip_address")
                        ((found_devices++))
                    fi
                fi
                
                rm -f "$resolve_file"
            fi
        fi
    done < <(grep -i shelly "$temp_file" 2>/dev/null)
    
    # Output results
    if [ $found_devices -gt 0 ]; then
        echo "✅ Found $found_devices Shelly device(s):"
        echo
        printf "%-35s %s\n" "Device Name" "IP Address"
        printf "%-35s %s\n" "━━━━━━━━━━━" "━━━━━━━━━━"
        
        for device in "${devices[@]}"; do
            hostname=$(echo "$device" | cut -d'|' -f1)
            ip_address=$(echo "$device" | cut -d'|' -f2)
            printf "%-35s %s\n" "$hostname" "$ip_address"
        done
    else
        echo "❌ No Shelly devices found on the network"
    fi
    
    # Clean up
    rm -f "$temp_file"
else
    echo "❌ Discovery failed - no results found"
fi

echo
echo "🏁 Discovery complete."