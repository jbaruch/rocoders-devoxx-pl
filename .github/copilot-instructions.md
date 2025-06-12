# Copilot Instructions: Vibecoding RGBW Control App

These instructions are for an agentic coding assistant (e.g., Copilot Agent in VS Code) to implement a real-time RGBW smart bulb control demo app for the Vibecoding conference.

> ⚠️ This project intentionally favors simplicity for a live coding session. Avoid production-level complexity like cloud dependencies, persistent storage, or build chains.

---

## 🧠 Agent Environment

This project assumes:

* **VS Code with Copilot Agent Mode** is active.
* **Context7 MCP is fully configured and running.**

  * Use it extensively for all Java 21, Spring Boot 3.5.
  * Use it for DOM APIs, camera access API.

* Refer to the [Requirements](../docs/Requirements.md) document for detailed functional scope, exclusions, and demo constraints.
---

## 🔧 Backend Responsibilities (Spring Boot 3.5, Java 21)

* Implement REST endpoint `POST /color` to receive `{ red, green, blue }` JSON.
* Shelly's bulb IP address will be provided via application properties file.
* Use `RestClient` to invoke `http://<bulb-ip>/light/0` with query parameters: `turn=on`, RGBW values, `gain=100`.
* White = `min(R,G,B)`
* Log and return errors for:
  * Timeout or bad HTTP status
* **CRITICAL: Configure HTTP timeouts** to prevent hanging:
  * Connect timeout: 2 seconds
  * Read timeout: 3 seconds
  * Use `SimpleClientHttpRequestFactory` with proper timeout configuration
  * This prevents the application from hanging when Shelly bulb is unreachable
---

## 🌐 Frontend Responsibilities (HTML + JS)

* Use plain HTML/JS with optional `htm/preact` or `lit-html` (from CDN).
* Show a live preview of the detected color.
* Button to manually send RGBW color to backend.
* Auto mode sends color every 3 seconds.
* Create a full-screen layout with large, visible components for demo purposes.
* Make slick, modern UI with clear visual feedback.

### 📹 Camera Access Implementation

Use the **WebRTC MediaDevices API** for all webcam functionality. 
Key patterns: 
- `navigator.mediaDevices.getUserMedia({ video: true })` for basic access, 
`enumerateDevices()` filtered by `kind === 'videoinput'` for camera selection dropdown, and `deviceId: { exact: selectedId }` constraints for camera switching. 
- Always implement proper stream management (store in variable, stop tracks when switching), error handling with try/catch blocks, and check browser compatibility (`!!navigator.mediaDevices`). 
- Connect streams to video elements via `srcObject` property.

---

## 📋 Reference

* These instructions are derived from the canonical [Requirements](../docs/Requirements.md) document.
* Use it for detailed functional scope, exclusions, and demo constraints.

## 📋 Implementation Planning (MANDATORY)

**BEFORE implementing any code, you MUST:**

1. **Create a detailed implementation plan** in `docs/plan.md` that includes:
   - Project structure breakdown (directories, files)
   - Backend implementation steps (classes, methods, configuration)
   - Frontend implementation steps (HTML structure, JS modules, UI components)
   - Integration points between frontend and backend
   - Testing approach for each component
   - Estimated implementation order and dependencies

2. **STOP and wait for user approval** of the plan before proceeding with any code implementation

3. **Get explicit user confirmation** that the plan is acceptable before writing any source code

> ⚠️ **CRITICAL**: Do not implement any code until the user has reviewed and approved the implementation plan. This ensures alignment and prevents wasted effort during the live demo.

## ✅ General Rules

* Use Context7 for **every code block** involving Spring Boot, frontend browser APIs.
* Do not use WebSocket, database, Redis, Docker, MQTT, or cloud services.
* Make each step demonstrable and readable for a live conference audience.
* Favor clarity over optimization.
* Commit incrementally with meaningful messages.
