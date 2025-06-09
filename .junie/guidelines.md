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

# Device discovery settings
device.discovery.enabled=true
device.discovery.timeout=5000

# Color processing settings
color.processing.update-interval=500
```

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
6. Use `@MockBean` to mock dependencies when needed

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
```java
System.out.println("[DEBUG_LOG] Your message here");
```

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
2. **Device Discovery Service**: Discovers Shelly devices on the local network using mDNS
3. **Bulb Control Service**: Communicates with the Shelly bulb via HTTP REST API
4. **Webcam Service**: Captures and processes webcam images

### Performance Considerations
- Optimize color extraction algorithm to reduce CPU usage
- Implement caching for device discovery results
- Batch color updates to reduce network traffic
- Use non-blocking I/O for device communication

### Troubleshooting
- Check network connectivity if device discovery fails
- Verify that the Shelly bulb is on the same network as the application
- Enable debug logging for detailed information
- Use browser developer tools to debug frontend issues

### Useful Resources
- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Shelly API Documentation](https://shelly-api-docs.shelly.cloud/)
- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)