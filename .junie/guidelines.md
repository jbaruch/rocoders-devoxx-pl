# RoboCoders AI Fokus - Development Guidelines

This document provides essential information for developers working on the RoboCoders AI Fokus project, specifically the RGBW Control App for webcam-controlled smart lighting.

## Build/Configuration Instructions

### Prerequisites
- Java 21 JDK
- Maven 3.8+
- Local network with Shelly Duo GU10 RGBW smart bulb(s)

### Project Setup
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd rocoders-ai-fokus
   ```

2. Build the project:
   ```bash
   mvn clean install
   ```

3. Run the application:
   ```bash
   mvn spring-boot:run
   ```

4. Access the application:
   - Open a web browser and navigate to `http://localhost:8080`

### Configuration Options
The application can be configured through `application.properties` or environment variables:

```properties
# Server configuration
server.port=8080

# Bulb configuration
bulb.ip=192.168.8.135

# Color processing settings
color.processing.update-interval=500
```

#### Finding Your Shelly Bulb IP
Use the provided discovery script to find Shelly devices on your network:

```bash
./scripts/discover-shelly-devices.sh
```

This script uses mDNS to discover Shelly devices on your local network and displays their IP addresses.

## Testing Information

### Running Tests
To run all tests:
```bash
mvn test
```

To run a specific test class:
```bash
mvn test -Dtest=ColorProcessingServiceTest
```

To run a specific test method:
```bash
mvn test -Dtest=ColorProcessingServiceTest#testCalculateBrightness
```

### Adding New Tests
1. Create test classes in the `src/test/java` directory, mirroring the package structure of the class being tested
2. Use JUnit 5 annotations (`@Test`, `@DisplayName`, etc.)
3. Follow the Arrange-Act-Assert pattern for test structure
4. Use `@SpringBootTest` for integration tests that require the Spring context
5. Use `@WebMvcTest` for controller tests
6. For Spring Boot 3.5+, use `@Import` with a configuration class to provide mocks:

```java
@WebMvcTest(YourController.class)
@Import(YourControllerTest.TestConfig.class)
public class YourControllerTest {

    @Configuration
    static class TestConfig {
        @Bean
        public YourService yourService() {
            return Mockito.mock(YourService.class);
        }
    }

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private YourService yourService;

    @Test
    public void testEndpoint() {
        // Test implementation
    }
}
```

### Test Example
Here's an example of a test for the `ColorProcessingService`:

```java
@SpringBootTest
public class ColorProcessingServiceTest {

    @Autowired
    private ColorProcessingService colorProcessingService;

    @Test
    @DisplayName("Test RGB to RGBW conversion")
    public void testConvertRgbToRgbw() {
        // Arrange
        Color rgbColor = new Color(100, 150, 200);

        // Act
        Color rgbwColor = colorProcessingService.convertRgbToRgbw(rgbColor);

        // Assert
        assertEquals(0, rgbwColor.getRed(), "Red component should be 0 after white extraction");
        assertEquals(50, rgbwColor.getGreen(), "Green component should be 50 after white extraction");
        assertEquals(100, rgbwColor.getBlue(), "Blue component should be 100 after white extraction");
    }
}
```

### Debugging Tests
Add debug logs to your tests using:

```
System.out.println("[DEBUG_LOG] Your message here");
```

### Integration Testing
For testing the integration with the Shelly bulb:

1. Ensure the bulb is connected to your network
2. Run the integration test script:
   ```bash
   ./scripts/test-integration.sh
   ```

3. For manual API testing, use the Shelly API test script:
   ```bash
   ./scripts/test-shelly-api.sh [command]
   ```
   Available commands: on, off, color, brightness, status, info, test-all

## Additional Development Information

### Code Style
- Follow standard Java code conventions
- Use 4 spaces for indentation
- Maximum line length: 120 characters
- Use meaningful variable and method names
- Add JavaDoc comments for public methods and classes

### Project Structure
- `src/main/java/com/robocoders/rgbw` - Main application code
  - `controller/` - REST controllers
  - `service/` - Business logic services
  - `model/` - Data models
  - `config/` - Configuration classes
  - `exception/` - Custom exceptions
  - `util/` - Utility classes
- `src/main/resources/` - Configuration files and static resources
- `src/test/java/` - Test classes

### Key Components
1. **Color Processing Service**: Handles color conversion and processing
   - Converts RGB to RGBW using the min(R,G,B) algorithm
   - Communicates with the Shelly bulb via REST API

2. **Color Controller**: Exposes REST endpoints for the frontend
   - `/color` - POST endpoint for processing color data
   - `/health` - GET endpoint for health checks

3. **Frontend**: HTML/JS application for webcam color detection
   - Uses getUserMedia API for webcam access
   - Extracts dominant color from webcam feed
   - Sends color data to backend via REST API

### Shelly Bulb API
The application communicates with the Shelly bulb using its REST API:

```
http://{bulb-ip}/light/0?turn=on&red={r}&green={g}&blue={b}&white={w}&gain=100
```

Parameters:
- `turn`: on/off
- `red`, `green`, `blue`, `white`: 0-255
- `gain`: 0-100 (brightness percentage)

### Performance Considerations
- The application uses RestClient with proper timeout configuration to prevent hanging when the bulb is unreachable
- Connect timeout: 2 seconds
- Read timeout: 3 seconds
- Use non-blocking I/O for device communication

### Troubleshooting
- If the application can't connect to the bulb, verify the bulb's IP address
- Use the discovery script to find Shelly devices on your network
- Check that the bulb is powered on and connected to the same network
- Verify network connectivity using the test-shelly-api.sh script
- Use browser developer tools to debug frontend issues

### Useful Resources
- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Shelly API Documentation](https://shelly-api-docs.shelly.cloud/)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
