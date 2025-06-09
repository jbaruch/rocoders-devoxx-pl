# RGBW Control App: Product Requirements Document
## Vibecoding Demo - Webcam-Controlled Smart Lighting

**Executive Summary:** A focused demonstration application that showcases agentic AI IDE capabilities by building a real-time webcam-to-smart-bulb color control system. The app extracts dominant colors from webcam feed and automatically controls a Shelly Duo GU10 RGBW smart bulb over the local network.

**Demo Goal:** Build an impressive 1-hour live coding demonstration that combines computer vision, IoT device control, and full-stack web development using modern technologies.

## 🎯 Project Scope & Architecture

**Core Functionality:**
- **Real-time webcam color extraction** → **automatic smart bulb control**
- **Local network operation** with zero cloud dependencies  
- **mDNS-based device discovery** for seamless setup
- **Manual/automatic mode toggle** for user control
- **Full-screen demo-optimized UI** for conference presentation

**Technology Stack:**
- **Backend:** Spring Boot 3.5 + Java 21 + Maven
- **Frontend:** Vanilla HTML5 + JavaScript (no frameworks)
- **Device:** Shelly Duo GU10 RGBW smart bulb (Gen 1)
- **Discovery:** mDNS for automatic device detection
- **Communication:** HTTP REST API calls

## 🔧 Backend Implementation (Spring Boot 3.5 + Java 21)

### Core Requirements

**Essential Features:**
- REST endpoint: `POST /color` - receives RGB data from frontend
- REST endpoint: `GET /discover` - triggers device discovery and returns bulb IP
- mDNS-based automatic Shelly device discovery on startup
- `RestClient` for HTTP communication with bulb 
- Basic error handling with timeouts and try/catch blocks
- Maven project structure with Spring Boot 3.5 parent

**API Integration Details:**
```java
// Primary endpoint for color control
POST /color
{
  "red": 120,
  "green": 80, 
  "blue": 200
}

// Device discovery endpoint  
GET /discover
{
  "deviceIp": "192.168.1.100",
  "deviceName": "shellycolorbulb-ABC123",
  "status": "found"
}
```

### Shelly REST API Integration

**Primary Control Endpoint:** `http://<bulb-ip>/color/0`

**Request Format:**
```http
GET http://192.168.1.100/color/0?turn=on&red=120&green=80&blue=200&white=40&gain=100
```

**Supported Parameters:**
- `turn=on|off|toggle` - Power control
- `red=0-255` - Red channel intensity
- `green=0-255` - Green channel intensity  
- `blue=0-255` - Blue channel intensity
- `white=0-255` - White channel intensity
- `gain=0-100` - Overall brightness/intensity
- `timer=X` - Auto-off timer in seconds

**Color Calculation Strategy:**
- Calculate white channel as `min(red, green, blue)` to reduce saturation
- Subtract white value from RGB channels for better color accuracy
- Set gain to 100 for maximum brightness in demo

### mDNS Device Discovery

**Discovery Pattern:**
- Shelly devices broadcast hostname: `shellycolorbulb-<MAC>.local`
- Service type: `_http._tcp.local` on port 80
- No authentication required for local network access
- Device responds to `/status` endpoint for identification

**Implementation Approach:**
```java
@Service
public class ShellyDiscoveryService {
    public Optional<ShellyDevice> discoverDevice() {
        // Use javax.jmdns or similar library
        // Scan for _http._tcp.local services
        // Filter for hostnames starting with "shellycolorbulb-"
        // Return IP address and device info
    }
}
```

### Excluded Features (Keep Simple)
- ❌ Circuit breakers or resilience patterns
- ❌ Connection pooling configuration
- ❌ WebSocket real-time communication  
- ❌ Health checks, Actuator endpoints, Prometheus metrics
- ❌ Database integration (Redis, PostgreSQL)
- ❌ Docker containerization
- ❌ MQTT or CoAP protocols

## 🎨 Frontend Implementation (htm/preact + lit-html)

### Core Requirements

**Essential Features:**
- `getUserMedia()` for webcam access with device enumeration
- **Webcam selector dropdown** for choosing proper camera device
- Simple color extraction using Color Thief library
- Large, visible color preview box for demo purposes
- Toggle switch: Manual/Auto mode control
- "Send to Bulb" button (enabled only in manual mode)
- Auto mode: send color updates every 3 seconds
- Call `/discover` API on page load to get bulb IP address
- **Demo-optimized UI:** Full-screen layout with oversized components

### Minimal Frontend Framework Setup

**htm/preact Integration:**
```html
<!-- CDN imports for minimal bundle -->
<script type="module">
  import { html, render } from 'https://unpkg.com/htm/preact/standalone.module.js';
  import { useState, useEffect } from 'https://unpkg.com/preact/hooks/dist/hooks.module.js';
</script>
```

**lit-html for Efficient Updates:**
```html
<script type="module">
  import { html, render } from 'https://unpkg.com/lit-html?module';
</script>
```

**Why These Libraries:**
- **htm/preact**: JSX-like syntax without build step, minimal (3KB)
- **lit-html**: Efficient DOM updates, template literals, 5KB
- **No build process**: Direct ES6 module imports from CDN
- **Fast development**: Component-based architecture for demo UI

### Webcam Integration with Device Selection

**Device Enumeration:**
```javascript
const [cameras, setCameras] = useState([]);
const [selectedCamera, setSelectedCamera] = useState('');

useEffect(() => {
  async function getCameras() {
    const devices = await navigator.mediaDevices.enumerateDevices();
    const videoDevices = devices.filter(device => device.kind === 'videoinput');
    setCameras(videoDevices);
    if (videoDevices.length > 0) {
      setSelectedCamera(videoDevices[0].deviceId);
    }
  }
  getCameras();
}, []);
```

**getUserMedia with Device Selection:**
```javascript
async function startCamera(deviceId) {
  try {
    const stream = await navigator.mediaDevices.getUserMedia({
      video: {
        deviceId: deviceId ? { exact: deviceId } : undefined,
        width: { ideal: 1280 },
        height: { ideal: 720 },
        frameRate: { ideal: 30 }
      }
    });
    videoElement.srcObject = stream;
  } catch (error) {
    console.error('Camera access failed:', error);
  }
}
```

**Webcam Selector Component:**
```javascript
const CameraSelector = ({ cameras, selectedCamera, onCameraChange }) => html`
  <div class="camera-selector">
    <label for="camera-select">📹 Select Camera:</label>
    <select 
      id="camera-select" 
      value=${selectedCamera}
      onChange=${(e) => onCameraChange(e.target.value)}
    >
      ${cameras.map(camera => html`
        <option value=${camera.deviceId}>
          ${camera.label || `Camera ${camera.deviceId.slice(0, 8)}...`}
        </option>
      `)}
    </select>
  </div>
`;
```

**Browser Support:**
- Chrome 59+ ✅ (enumerateDevices full support)
- Firefox 52+ ✅ (deviceId constraint support)
- Safari 11+ ✅ (basic getUserMedia support)
- Edge 79+ ✅ (full feature parity)
- Requires HTTPS in production

### Color Extraction Strategy

**Library Choice: Color Thief**
- Lightweight (~8KB minified)
- Simple API: `colorThief.getColor(imageElement)`
- Returns RGB array: `[120, 80, 200]`
- Optimized for real-time processing

**Implementation with htm/preact:**
```javascript
const ColorExtractor = ({ videoRef, onColorChange }) => {
  const extractColor = () => {
    if (!videoRef.current) return;
    
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    
    canvas.width = videoRef.current.videoWidth;
    canvas.height = videoRef.current.videoHeight;
    ctx.drawImage(videoRef.current, 0, 0);
    
    const colorThief = new ColorThief();
    const dominantColor = colorThief.getColor(canvas);
    
    const color = {
      red: dominantColor[0],
      green: dominantColor[1], 
      blue: dominantColor[2]
    };
    
    onColorChange(color);
  };
  
  useEffect(() => {
    const interval = setInterval(extractColor, 100); // 10 FPS
    return () => clearInterval(interval);
  }, []);
  
  return null; // Pure logic component
};
```

### Main Application Component

**Full App Structure with htm/preact:**
```javascript
const App = () => {
  const [cameras, setCameras] = useState([]);
  const [selectedCamera, setSelectedCamera] = useState('');
  const [currentColor, setCurrentColor] = useState({ red: 0, green: 0, blue: 0 });
  const [isAutoMode, setIsAutoMode] = useState(false);
  const [deviceIp, setDeviceIp] = useState('');
  const [status, setStatus] = useState('Initializing...');
  const videoRef = useRef();

  // Device discovery on load
  useEffect(() => {
    fetch('/discover')
      .then(res => res.json())
      .then(data => {
        setDeviceIp(data.deviceIp);
        setStatus(`Connected to: ${data.deviceName}`);
      })
      .catch(() => setStatus('No device found'));
  }, []);

  const sendColorToBulb = async (color) => {
    try {
      const response = await fetch('/color', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(color)
      });
      if (response.ok) {
        setStatus('✅ Color sent successfully');
      }
    } catch (error) {
      setStatus('❌ Failed to send color');
    }
  };

  return html`
    <div class="app">
      <h1>🎨 RGBW Webcam Control</h1>
      
      <${CameraSelector} 
        cameras=${cameras}
        selectedCamera=${selectedCamera}
        onCameraChange=${setSelectedCamera}
      />
      
      <div class="video-container">
        <video 
          ref=${videoRef}
          autoplay 
          muted 
          playsinline
          class="webcam-feed"
        />
      </div>
      
      <${ColorPreview} color=${currentColor} />
      
      <${ModeToggle} 
        isAutoMode=${isAutoMode}
        onToggle=${setIsAutoMode}
      />
      
      ${!isAutoMode && html`
        <button 
          class="send-button"
          onClick=${() => sendColorToBulb(currentColor)}
        >
          💡 Send to Bulb
        </button>
      `}
      
      <div class="status">${status}</div>
      
      <${ColorExtractor} 
        videoRef=${videoRef}
        onColorChange=${(color) => {
          setCurrentColor(color);
          if (isAutoMode) {
            sendColorToBulb(color);
          }
        }}
      />
    </div>
  `;
};
```

### UI Component Library

**Color Preview Component:**
```javascript
const ColorPreview = ({ color }) => {
  const { red, green, blue } = color;
  const colorStyle = `rgb(${red}, ${green}, ${blue})`;
  
  return html`
    <div class="color-preview">
      <div 
        class="color-square"
        style="background-color: ${colorStyle}"
      ></div>
      <div class="color-values">
        <span>R: ${red}</span>
        <span>G: ${green}</span>
        <span>B: ${blue}</span>
      </div>
    </div>
  `;
};
```

**Mode Toggle Component:**
```javascript
const ModeToggle = ({ isAutoMode, onToggle }) => html`
  <div class="mode-toggle">
    <label class="toggle-label">
      <input 
        type="checkbox"
        checked=${isAutoMode}
        onChange=${(e) => onToggle(e.target.checked)}
      />
      <span class="toggle-slider"></span>
      <span class="toggle-text">
        ${isAutoMode ? '🔄 Auto Mode' : '👆 Manual Mode'}
      </span>
    </label>
  </div>
`;
```

### Demo-Optimized CSS

**Full-Screen Layout:**
```css
.app {
  display: grid;
  grid-template-areas: 
    "header header"
    "camera video"
    "preview controls"
    "status status";
  grid-template-columns: 1fr 1fr;
  height: 100vh;
  padding: 20px;
  font-family: 'Segoe UI', system-ui, sans-serif;
}

.color-square {
  width: 300px;
  height: 300px;
  border-radius: 20px;
  border: 4px solid #333;
  transition: background-color 0.3s ease;
}

.send-button {
  background: linear-gradient(45deg, #FF6B6B, #4ECDC4);
  border: none;
  color: white;
  padding: 20px 40px;
  font-size: 24px;
  border-radius: 15px;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.send-button:hover {
  transform: scale(1.05);
}

.toggle-slider {
  width: 80px;
  height: 40px;
  background: #ccc;
  border-radius: 20px;
  position: relative;
  transition: 0.3s;
}

.camera-selector select {
  padding: 15px;
  font-size: 18px;
  border-radius: 10px;
  border: 2px solid #ddd;
  min-width: 300px;
}
```

### Auto/Manual Mode Logic with Enhanced UX

**Auto Mode (3-second intervals):**
```javascript
useEffect(() => {
  if (!isAutoMode) return;
  
  const autoInterval = setInterval(() => {
    if (currentColor.red || currentColor.green || currentColor.blue) {
      sendColorToBulb(currentColor);
    }
  }, 3000);
  
  return () => clearInterval(autoInterval);
}, [isAutoMode, currentColor]);
```

**Enhanced Status Feedback:**
```javascript
const StatusDisplay = ({ status, deviceIp, isAutoMode, currentColor }) => html`
  <div class="status-panel">
    <div class="connection-status">
      <span class="status-indicator ${deviceIp ? 'connected' : 'disconnected'}"></span>
      ${deviceIp ? `🔗 ${deviceIp}` : '❌ No device'}
    </div>
    <div class="mode-status">
      ${isAutoMode ? '🔄 Auto (3s intervals)' : '👆 Manual control'}
    </div>
    <div class="color-info">
      RGB: ${currentColor.red}, ${currentColor.green}, ${currentColor.blue}
    </div>
    <div class="system-status">${status}</div>
  </div>
`;
```

### Frontend Dependencies (CDN)

**Essential Libraries:**
```html
<!DOCTYPE html>
<html>
<head>
  <title>RGBW Webcam Control</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
  <!-- Color extraction library -->
  <script src="https://cdn.jsdelivr.net/npm/colorthief@2.3.0/dist/color-thief.umd.js"></script>
  
  <!-- Frontend framework (choose one approach) -->
  
  <!-- Option 1: htm/preact (recommended for component structure) -->
  <script type="module">
    import { html, render } from 'https://unpkg.com/htm/preact/standalone.module.js';
    import { useState, useEffect, useRef } from 'https://unpkg.com/preact/hooks/dist/hooks.module.js';
    
    // App components here...
    render(html`<${App} />`, document.body);
  </script>
  
  <!-- Option 2: lit-html (alternative for template efficiency) -->
  <script type="module">
    import { html, render } from 'https://unpkg.com/lit-html?module';
    
    // Template-based approach...
  </script>
</body>
</html>
```

**Bundle Sizes:**
- **htm/preact**: ~6KB total (htm 2KB + preact 4KB)
- **lit-html**: ~5KB for efficient templating
- **Color Thief**: ~8KB for color extraction
- **Total**: Under 15KB - perfect for demo performance

### Excluded Frontend Features
- ❌ Complex build processes or bundlers
- ❌ WebSocket real-time communication
- ❌ Complex color algorithms (K-means, HSL conversion)
- ❌ Web Workers for processing
- ❌ OffscreenCanvas optimization
- ❌ Advanced camera constraint configuration UI
- ❌ Color temperature or Kelvin calculations
- ❌ Heavy CSS frameworks (Bootstrap, Tailwind)

## 💡 Shelly Integration Deep Dive

### Device Specifications
- **Model:** Shelly Duo GU10 RGBW (SHCB-1)
- **Type:** Generation 1 device with HTTP REST API
- **Network:** WiFi 2.4GHz, no hub required
- **Authentication:** None required for local network access
- **Discovery:** mDNS hostname format: `shellycolorbulb-<MAC>.local`

### REST API Endpoints

**Primary Color Control:**
```http
GET http://<bulb-ip>/color/0?turn=on&red=255&green=86&blue=112&white=0&gain=100
```

**Status Check:**
```http
GET http://<bulb-ip>/status
```

**Device Info:**
```http
GET http://<bulb-ip>/shelly
```

### Color Processing Strategy

**RGB to RGBW Conversion:**
```javascript
function calculateRGBW(rgb) {
  const white = Math.min(rgb.red, rgb.green, rgb.blue);
  return {
    red: rgb.red - white,
    green: rgb.green - white, 
    blue: rgb.blue - white,
    white: white,
    gain: 100  // Maximum brightness for demo
  };
}
```

**Benefits:**
- Reduces color saturation by extracting white component
- Improves color accuracy and brightness
- Maximizes white LED utilization for energy efficiency

### Error Handling Requirements

**Backend Error Scenarios:**
- Device not found (404)
- Network timeout
- Invalid color values
- Device unreachable

**Frontend Error Scenarios:**
- Camera access denied
- No device discovered
- API call failures
- Color extraction errors

## 🎪 Live Demo Flow

### Setup Phase (30 seconds)
1. **Launch application** → Backend starts, frontend loads
2. **Automatic device discovery** → mDNS scan finds Shelly bulb
3. **Camera activation** → getUserMedia requests webcam access
4. **UI initialization** → Full-screen demo interface appears

### Demo Scenarios (25 minutes)

**Scenario 1: Manual Color Control**
1. Show colored object to camera
2. Color preview updates in real-time
3. Click "Send to Bulb" button
4. Bulb instantly changes to detected color
5. Demonstrate with multiple colored objects

**Scenario 2: Automatic Mode**
1. Toggle to Auto mode
2. Colors automatically sync every 3 seconds
3. Move different colored objects around
4. Show real-time bulb responses
5. Highlight responsiveness and accuracy

**Scenario 3: Technical Deep Dive**
1. Show backend REST API calls in browser dev tools
2. Demonstrate mDNS device discovery process
3. Explain color processing algorithm
4. Show RGB to RGBW conversion in action

### Success Metrics
- ✅ **Sub-second response time** from color detection to bulb change
- ✅ **Accurate color reproduction** across different lighting conditions  
- ✅ **Zero configuration** device discovery and setup
- ✅ **Reliable operation** throughout entire demo period
- ✅ **Visual impact** that impresses conference audience

## 🚀 Implementation Priority

### Phase 1: Core Backend (15 minutes)
- Spring Boot project setup with Maven
- Shelly REST API integration with RestClient
- Basic color endpoint implementation
- Simple error handling

### Phase 2: Device Discovery (10 minutes)  
- mDNS discovery service implementation
- Device discovery endpoint
- Connection validation

### Phase 3: Frontend Foundation (15 minutes)  
- HTML structure with htm/preact components
- Webcam integration with device enumeration and selection
- Color Thief library integration with real-time extraction
- API communication layer with error handling
- Demo-optimized styling with CSS Grid layout

### Phase 4: Demo Polish (15 minutes)
- UI styling for presentation
- Auto/manual mode toggle
- Error handling and status display
- Final testing and optimization

### Phase 5: Demo Rehearsal (5 minutes)
- End-to-end testing
- Performance validation
- Backup scenarios preparation

## 🔧 Development Setup

### Required Dependencies

**Backend (Maven):**
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
    <groupId>org.jmdns</groupId>
    <artifactId>jmdns</artifactId>
    <version>3.5.8</version>
</dependency>
```

**Frontend (CDN):**
```html
<!-- Minimal frontend framework -->
<script type="module" src="https://unpkg.com/htm/preact/standalone.module.js"></script>
<script type="module" src="https://unpkg.com/preact/hooks/dist/hooks.module.js"></script>

<!-- Color extraction -->
<script src="https://cdn.jsdelivr.net/npm/colorthief@2.3.0/dist/color-thief.umd.js"></script>
```

### Local Development

**Prerequisites:**
- Java 21 JDK
- Maven 3.8+
- Modern browser with webcam
- Shelly Duo GU10 RGBW on local network

**Startup Commands:**
```bash
mvn spring-boot:run
# Access: http://localhost:8080
```

## 📋 Testing Strategy

### Unit Testing
- REST API endpoint validation
- Color conversion algorithm accuracy
- Error handling scenarios

### Integration Testing  
- Shelly device communication
- mDNS discovery reliability
- End-to-end color processing pipeline

### Demo Testing
- Camera access across different devices
- Network reliability with multiple devices
- Performance under presentation conditions

### Fallback Plans
- Mock device responses if bulb unavailable
- Static color examples if camera fails
- Presentation slides for technical explanation backup

## 🎯 Success Criteria

**Technical Requirements:**
- ✅ Application runs locally without external dependencies
- ✅ Automatic device discovery works reliably  
- ✅ Color extraction and bulb control under 1-second latency
- ✅ Stable operation throughout 45-minute demo window
- ✅ Clean, professional UI suitable for large screen presentation

**Demo Impact:**
- ✅ Audience engagement through interactive color demonstration
- ✅ Clear illustration of agentic AI IDE capabilities
- ✅ Smooth technical execution without errors or delays
- ✅ Compelling narrative of modern full-stack development
- ✅ Memorable demonstration of IoT integration capabilities

This PRD provides a focused roadmap for building an impressive conference demonstration that showcases both technical depth and practical IoT application development using modern tools and frameworks.