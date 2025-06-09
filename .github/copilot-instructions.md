# Copilot Instructions: Vibecoding RGBW Control App

These instructions guide an agentic AI coding assistant to implement a live demo app that controls a Shelly Duo GU10 RGBW smart bulb based on real-time webcam color detection.

> ✅ This project **intentionally prioritizes simplicity** for a live demo. All complex infrastructure (discovery, DB, cloud) is excluded by design.

## Agent Environment

This project is designed for **VS Code with GitHub Copilot Agent Mode enabled**. The workspace is preconfigured:

* **Agent Mode is active** — Copilot can run code, tests, and apply fixes autonomously.
* **Context7 MCP is fully set up and running** — use it for all Java, Spring Boot, and Puppeteer API lookups.
*

---

## 🖥 Backend Instructions (Spring Boot 3.5 + Java 21)

### Responsibilities

* Build a Spring Boot 3.5 app using Java 21.
* Use **Context7 MCP** to look up all Java and Spring Boot APIs accurately.
* Implement a REST endpoint `POST /color` that accepts RGB values (`{ red, green, blue }`).
* Use `RestClient` to send those values to `http://<bulb-ip>/light/0` with appropriate parameters.
* Basic error handling using try/catch and timeouts.
* Exclude any complex resilience or observability patterns.

### Shelly Bulb Integration

* Bulb must be turned on with parameters:

  * `red`, `green`, `blue`, `white` (calculated as `min(R,G,B)`)
  * `gain=100`
  * `turn=on`
* Do not use `/color/0`, `/white/0`, or any non-documented endpoints.

### Testing

* Write unit tests with JUnit 5.
* Use **Context7 MCP** for API correctness.
* Include tests for:

  * Valid RGB payload
  * Missing or malformed input
  * IP address validation and HTTP failures

---

## 🌐 Frontend Instructions (HTML + JavaScript)

### Responsibilities

* Build the UI with **vanilla HTML and JavaScript**.
* Use **Context7 MCP** to guide usage of DOM APIs and Puppeteer when applicable.
* You may use **htm/preact** or **lit-html** (from CDN only) for DOM composition — no build tools.
* Use `getUserMedia` to access webcam.
* Use Color Thief or similar for dominant color extraction.

### Interface Requirements

* Input field for bulb IP address (required before sending colors)
* Color preview box
* Mode toggle (Manual/Auto)
* "Send to Bulb" button (Manual mode only)
* Auto mode sends every 3 seconds
* UI must be optimized for large screen presentation:

  * Full-screen layout
  * Large buttons and preview elements

### Testing

* Use **Puppeteer MCP** to run UI tests:

  * Load page and enter valid IP
  * Toggle modes and click buttons
  * Capture screenshots before and after
  * Verify UI state and color preview

---

## General Guidelines

* Follow the structure and exclusions from the [Requirements](./requirements.md).
* Prioritize clear, readable, live-demo-friendly code.
* No cloud services, no async message queues, no databases.
* Manual IP entry only — no mDNS or network scanning.
* Avoid overengineering — this project is a live co-coding demo, not production software.
* Use `context7` for all library and language references to avoid hallucinations or outdated code.
