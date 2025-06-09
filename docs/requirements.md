# Shelly Duo GU10 RGBW Control Application: Comprehensive Technical Requirements

Spring Boot 3.5 with Java 21 provides the foundation for a robust IoT lighting control system that combines real-time webcam color extraction with local network device management. **The architecture separates concerns effectively**: a client-side web application handles camera capture and color processing, while the Spring Boot backend manages all Shelly device communication through REST APIs. This design maximizes performance by processing colors locally in the browser while centralizing device control logic in a scalable Java backend.

The implementation leverages modern web technologies including the getUserMedia API for camera access, advanced color extraction algorithms for real-time processing, and WebSocket connections for instant communication between frontend and backend. Local network deployment ensures low latency and eliminates cloud dependencies, while comprehensive error handling and device discovery patterns provide enterprise-grade reliability for smart home automation.

## Shelly Duo GU10 RGBW device integration

The Shelly Duo GU10 RGBW smart light bulb (model SHCB-1) operates as a Generation 1 device with comprehensive REST API support for local network control. **The device supports full RGBW color control with 8-bit precision** (0-255) for each channel, plus brightness control from 0-100% and color temperature adjustment from 3000K-6500K.

### Core API endpoints and capabilities

The device exposes multiple REST endpoints at `http://[device-ip]/[endpoint]` with no authentication required by default for local network access. **Primary control endpoints include `/light/0` for basic operations, `/color/0` for RGBW control, and `/white/0` for color temperature management**. The `/status` endpoint provides complete device state including power consumption and connectivity status.

Color control supports multiple formats: RGBW values with individual channel control, color temperature with brightness, and gain adjustment affecting all channels simultaneously. **Transition effects enable smooth color changes up to 5 seconds duration**, while built-in lighting effects include meteor shower, gradual change, flash, and breath patterns. Advanced features include scheduling with up to 20 rules, timer functions, and automatic state restoration options.

### Network discovery and device management  

Device discovery utilizes mDNS with hostname format `shellycolorbulb-<MAC>.local.` broadcasting on `_http._tcp.local.` service type. **The device operates in AP mode initially** with SSID `shellycolorbulb-<MAC>` for configuration, then connects to existing WiFi networks as a client. Manual network scanning can locate devices by scanning port 80 across local subnets and identifying Shelly devices through their response headers.

Rate limiting considerations include avoiding rapid concurrent requests due to single-threaded processing limitations. **Best practices require sequential command execution with error handling** for network timeouts and device unavailability. Connection pooling should be configured with appropriate timeouts: 5-second connect timeout and 10-second read timeout for optimal local network performance.

## Spring Boot 3.5 backend architecture

Spring Boot 3.5 with Java 21 introduces enhanced REST client capabilities through the new RestClient API, superseding RestTemplate for synchronous operations. **RestClient provides fluent API design with better performance and modern configuration options**, making it ideal for IoT device communication patterns. WebClient remains recommended for reactive operations requiring non-blocking behavior.

### HTTP client implementation patterns

Connection pooling configuration utilizes HttpComponentsClientHttpRequestFactory with PoolingHttpClientConnectionManager supporting 50 total connections and 20 per-route limits. **Timeout configuration includes 5-second connection timeout, 10-second read timeout, and automatic retry strategy with exponential backoff** starting at 1-second delay with 2x multiplier up to 3 attempts maximum.

Circuit breaker patterns prevent cascading failures through Resilience4j integration with failure thresholds at 50% over 100-request sliding windows. **Recovery mechanisms include fallback methods returning cached device states** when primary communication fails, maintaining system stability during network issues or device unavailability.

### WebSocket real-time communication

WebSocket integration uses Spring's @EnableWebSocketMessageBroker with STOMP protocol for structured messaging. **Configuration supports both /topic broadcasts for general updates and /user/queue for personalized device commands**. Message handling includes automatic reconnection with exponential backoff, heartbeat mechanisms every 30 seconds, and comprehensive error recovery procedures.

CORS configuration accommodates local development with allowed origin patterns for localhost and local network addresses. **Security headers include proper credential handling and preflight request support** for browser compatibility across development and production environments.

### Error handling and monitoring

Global exception handling addresses common IoT scenarios including device timeouts, network failures, and unavailable devices. **Custom health indicators monitor device connectivity** with metrics tracking total devices, active devices, and last communication timestamps. Circuit breaker patterns provide automatic recovery with 30-second open-state timeouts and half-open testing procedures.

Comprehensive logging configuration separates IoT operations into dedicated log files with rolling policies maintaining 30 days of history at 100MB maximum size. **Spring Boot Actuator integration enables Prometheus metrics export** with custom tags for application identification and environment classification.

## Web frontend and color processing

Modern browser webcam access utilizes the getUserMedia API requiring HTTPS in production environments with comprehensive browser support including Chrome 59+, Firefox 52+, Safari 11+, and Edge 79+. **Camera constraints configuration enables resolution selection up to 1920x1080, frame rate control up to 60fps, and rear camera preference** through facingMode settings.

### Real-time color extraction algorithms

Color extraction employs multiple algorithmic approaches optimized for real-time performance. **K-means clustering provides accurate results for complex images** but requires multiple iterations, while color histogram analysis offers faster processing suitable for real-time applications with single-pass pixel processing.

Performance optimization techniques include image downsampling with quality parameters (5-20 recommended for real-time processing), Web Worker utilization for non-blocking computation, and OffscreenCanvas support reducing main thread blocking by 40%. **Memory management strategies reuse canvas contexts and ImageData objects** while implementing efficient pixel data handling through typed arrays.

### Color space conversions and formatting

RGB to RGBW conversion calculates white components as the minimum RGB value, subtracting white from each color channel to maintain color accuracy while maximizing white LED utilization. **HSL transformations enable intuitive color manipulation** while Kelvin to RGB conversion supports color temperature calculations for warm-to-cool lighting effects.

Recommended JavaScript libraries include Color Thief (8KB) for optimized real-time extraction, Chroma.js (13KB) for comprehensive color manipulation, and Vibrant.js (15KB) for Material Design-inspired palettes. **WebSocket client implementation includes automatic reconnection handling, message throttling, and connection state management** for reliable backend communication.

## System integration and architecture

Local network communication architecture implements layered design separating device, network, gateway, and application layers. **Network segmentation utilizes VLANs isolating IoT devices from main networks** with firewall rules restricting inter-device communication while allowing controller access.

### Device discovery and connection management

Multiple discovery protocols support different device types and network configurations. **mDNS provides automatic service discovery** with .local domain resolution, while UPnP/SSDP enables broader device compatibility through standardized discovery mechanisms. Custom broadcast protocols on UDP port 8888 support proprietary device types with JSON-based capability announcement.

Connection pooling strategies maintain persistent HTTP connections with keep-alive timeout at 300 seconds and validation queries every 60 seconds. **WebSocket connections implement heartbeat mechanisms** with automatic reconnection using exponential backoff algorithms starting at 1-second delays up to 300-second maximums with ±25% jitter.

### Security and performance optimization

Security implementation includes certificate-based authentication with X.509 certificates and local PKI, plus token-based systems using JWT with 24-hour rotation cycles. **TLS 1.3 encryption protects all communications** while hardware security modules provide tamper-resistant key storage for enterprise deployments.

Performance optimization addresses latency through QoS configuration prioritizing IoT traffic, multi-level caching with 30-second TTL for dynamic values, and rate limiting preventing device overload. **Throttling mechanisms limit control commands to 10 requests/minute per device** while supporting burst traffic through token bucket algorithms.

## Implementation recommendations

Development environment setup requires Docker Desktop for containerization, PostgreSQL for data persistence, Redis for session management, and Eclipse Mosquitto for MQTT messaging. **Maven configuration includes Spring Boot 3.5 parent with Java 21 compiler settings** plus dependencies for WebFlux, WebSocket, Actuator, and Resilience4j circuit breakers.

Deployment strategies support both single-server configurations for small installations and distributed architectures for enterprise scale. **Container orchestration through Docker Compose** enables easy local deployment while Kubernetes provides horizontal scaling for installations exceeding 500 devices.

Scalability patterns accommodate growth from single-controller deployments supporting 1-50 devices through microservices architectures handling 500+ devices with distributed databases and message queue systems. **Performance monitoring includes real-time metrics collection** with capacity planning alerts and automated scaling triggers.

## Conclusion

This comprehensive technical specification provides complete implementation guidance for a Shelly Duo GU10 RGBW control application combining webcam-based color extraction with robust backend device management. The architecture ensures real-time performance through client-side processing while maintaining centralized control logic for scalability and reliability. Security patterns protect local network deployments while comprehensive error handling ensures graceful degradation during network issues or device failures.