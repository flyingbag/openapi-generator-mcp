# Petstore MCP Server - Java Example

Example implementation of an MCP server for the Petstore API using Spring AI and Java.

## Prerequisites

- Java 17+
- Maven 3.6+

## Project Structure

```
src/main/java/com/example/petstore/
└── PetstoreMcpApplication.java    # Main Spring Boot application

src/main/resources/
└── application.properties          # MCP server configuration

# Generated code (copy from ../../generated/java-mcp/)
io/github/openapi/mcp/api/
├── PetApiMcpToolsBase.java
├── StoreApiMcpToolsBase.java
└── UserApiMcpToolsBase.java
```

## Usage

1. Copy generated code from `../../generated/java-mcp/` to this project

2. Build the project:
```bash
mvn clean install
```

3. Run the MCP server:
```bash
mvn spring-boot:run
```

## Implementing Custom Business Logic

Extend the generated base classes to add your business logic:

```java
@Service
public class PetApiMcpTools extends PetApiMcpToolsBase {

    @Autowired
    private PetService petService;

    @Override
    public Pet getPetById(Long petId) {
        // Implement your business logic
        return petService.findById(petId)
            .orElseThrow(() -> new PetNotFoundException(petId));
    }
}
```

## Configuration

Configure the MCP server in `application.properties`:

```properties
# MCP Transport (stdio, sse, or http)
spring.ai.mcp.transport=stdio

# Server port
server.port=8080
```

## Testing with MCP Inspector

```bash
npx @modelcontextprotocol/inspector java -jar target/petstore-mcp-1.0.0.jar
```
