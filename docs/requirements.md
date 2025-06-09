# Vibecoding Demo: RGBW Control App Requirements

This specification outlines a practical and impressive application for a 1-hour Vibecoding conference demo using agentic AI IDEs. The app controls a Shelly Duo GU10 RGBW smart bulb based on real-time color extraction from a webcam feed.

---

## Project Goal

Build a **web app that uses your webcam to detect dominant color and control a Shelly Duo GU10 RGBW bulb** over the local network.

* No manual IP input — uses mDNS-based **automatic device discovery**
* Toggle between **manual or automatic color updates**
* Entire app runs locally with no cloud dependency

---

## 🔧 Backend (Spring Boot 3.5, Java 21)

**Include:**

* Java 21 + Spring Boot 3.5 app
* REST endpoint: `POST /color` accepts RGB data from frontend
* Use `RestClient` to call `http://<bulb-ip>/color/0`
* mDNS-based **local device discovery** on startup or `/discover` endpoint
* Basic error handling (try/catch, timeouts)

**Skip:**

* Circuit breakers
* Connection pooling configuration
* WebSocket
* Health checks / Actuator / Prometheus
* Redis, PostgreSQL, Docker, MQTT

---

## Frontend (HTML + JS)

**Include:**

* `getUserMedia` for webcam access
* Simple color extraction (e.g. Color Thief)
* Show color preview box
* Toggle switch: Manual / Auto
* Button: “Send to Bulb” (only enabled in manual mode)
* If Auto mode is enabled, send color every 3 seconds
* Call `/discover` on load to fetch Shelly bulb IP
* **UI optimized for large screen demos:** full-screen layout with large, clearly visible components (preview box, toggle, and buttons)

**Skip:**

* WebSockets
* K-means, OffscreenCanvas, Web Workers
* HSL, Kelvin, or complex color math
* Camera constraint configuration

---

## 💡 Shelly Integration

* Use Shelly REST API at `/color/0`
* Example payload:

  ```json
  { "red": 120, "green": 80, "blue": 200, "gain": 100 }
  ```
* Calculate white as `min(R,G,B)` to reduce color saturation
* Skip `/white/0`, `/light/0`, and advanced features

---

## Live Demo Flow

1. User opens the web app → webcam activates
2. Shelly bulb is discovered automatically
3. Color is shown live on screen
4. User toggles between auto and manual mode
5. Bulb updates based on detected color