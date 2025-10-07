package com.example.petstore;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.ai.mcp.spring.ToolCallback;
import org.springframework.ai.mcp.spring.ToolCallbacks;

import io.github.openapi.mcp.api.PetApiMcpToolsBase;
import io.github.openapi.mcp.api.StoreApiMcpToolsBase;
import io.github.openapi.mcp.api.UserApiMcpToolsBase;

import java.util.List;

/**
 * Example MCP Server implementation for Petstore API in Java (Spring AI)
 * This demonstrates how to use the generated MCP tools
 */
@SpringBootApplication
public class PetstoreMcpApplication {

    public static void main(String[] args) {
        SpringApplication.run(PetstoreMcpApplication.class, args);
    }

    /**
     * Register MCP tools as Spring beans
     * The Spring AI MCP framework will automatically discover and expose these tools
     */
    @Bean
    public List<ToolCallback> mcpTools(
            PetApiMcpToolsBase petTools,
            StoreApiMcpToolsBase storeTools,
            UserApiMcpToolsBase userTools) {

        // Convert generated tool classes to ToolCallbacks
        return List.of(
            ToolCallbacks.from(petTools),
            ToolCallbacks.from(storeTools),
            ToolCallbacks.from(userTools)
        );
    }
}
