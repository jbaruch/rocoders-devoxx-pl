#!/bin/bash

# Shelly Bulb API Test Script
# IP Address: 192.168.8.135
# Usage: ./test-shelly-api.sh [command]

BULB_IP="192.168.8.135"

echo "=== Shelly Bulb API Test Commands ==="
echo "Bulb IP: $BULB_IP"
echo ""

case "${1:-help}" in
    "on")
        echo "Turning bulb ON with orange color..."
        curl "http://$BULB_IP/color/0?turn=on&red=255&green=128&blue=64&white=0&gain=80"
        ;;
    "off")
        echo "Turning bulb OFF..."
        curl "http://$BULB_IP/color/0?turn=off"
        ;;
    "color")
        echo "Setting color to purple..."
        curl "http://$BULB_IP/color/0?red=120&green=80&blue=200&white=0"
        ;;
    "brightness")
        echo "Setting brightness to 50%..."
        curl "http://$BULB_IP/color/0?gain=50"
        ;;
    "timer")
        echo "Setting auto-off timer to 300 seconds..."
        curl "http://$BULB_IP/color/0?timer=300"
        ;;
    "toggle")
        echo "Toggling bulb state..."
        curl "http://$BULB_IP/color/0?turn=toggle"
        ;;
    "status")
        echo "Getting device status..."
        curl "http://$BULB_IP/status"
        ;;
    "info")
        echo "Getting device info..."
        curl "http://$BULB_IP/shelly"
        ;;
    "test-all")
        echo "Running all test commands..."
        echo ""
        echo "1. Device info:"
        curl "http://$BULB_IP/shelly"
        echo -e "\n\n2. Device status:"
        curl "http://$BULB_IP/status"
        echo -e "\n\n3. Turn on with red color:"
        curl "http://$BULB_IP/color/0?turn=on&red=255&green=0&blue=0&white=0&gain=100"
        sleep 2
        echo -e "\n\n4. Change to green:"
        curl "http://$BULB_IP/color/0?red=0&green=255&blue=0&white=0"
        sleep 2
        echo -e "\n\n5. Change to blue:"
        curl "http://$BULB_IP/color/0?red=0&green=0&blue=255&white=0"
        sleep 2
        echo -e "\n\n6. Turn off:"
        curl "http://$BULB_IP/color/0?turn=off"
        ;;
    "help"|*)
        echo "Available commands:"
        echo "  on         - Turn bulb on with orange color"
        echo "  off        - Turn bulb off"
        echo "  color      - Set color to purple"
        echo "  brightness - Set brightness to 50%"
        echo "  timer      - Set auto-off timer (300s)"
        echo "  toggle     - Toggle bulb state"
        echo "  status     - Get device status"
        echo "  info       - Get device info"
        echo "  test-all   - Run full test sequence"
        echo ""
        echo "Manual curl examples:"
        echo "  curl \"http://$BULB_IP/color/0?turn=on&red=255&green=128&blue=64&white=0&gain=80\""
        echo "  curl \"http://$BULB_IP/color/0?turn=off\""
        echo "  curl \"http://$BULB_IP/color/0?red=120&green=80&blue=200&white=0\""
        echo "  curl \"http://$BULB_IP/color/0?gain=50\""
        echo "  curl \"http://$BULB_IP/color/0?timer=300\""
        echo "  curl \"http://$BULB_IP/color/0?turn=toggle\""
        echo "  curl \"http://$BULB_IP/status\""
        echo "  curl \"http://$BULB_IP/shelly\""
        echo ""
        echo "Parameters:"
        echo "  RGB values: 0-255"
        echo "  White value: 0-255" 
        echo "  Gain (brightness): 0-100%"
        ;;
esac

echo ""