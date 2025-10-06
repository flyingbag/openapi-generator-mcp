#!/usr/bin/env node
/**
 * Example TypeScript MCP Server using generated Petstore API tools.
 *
 * This example demonstrates how to use the generated MCP tools with
 * a TypeScript MCP server implementation.
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { Tool, TextContent } from "@modelcontextprotocol/sdk/types.js";

// Import generated MCP tools (after generation)
// import { PetApiMcpToolBase, StoreApiMcpToolBase, UserApiMcpToolBase } from "../generated/typescript-mcp/index.js";

/**
 * Service implementation that communicates with Petstore API.
 *
 * This service acts as a bridge between MCP tools and the Petstore REST API via HTTP.
 */
class PetstoreService {
  private baseUrl: string;

  /**
   * Initialize Petstore service.
   * @param apiBaseUrl - Base URL of Petstore API
   */
  constructor(apiBaseUrl: string = "https://petstore3.swagger.io/api/v3") {
    this.baseUrl = apiBaseUrl;
    console.log(`Initialized Petstore service: ${apiBaseUrl}`);
  }

  /**
   * Get pet by ID from Petstore API.
   * @param petId - Pet ID to fetch
   * @returns Pet information
   */
  async getPetById(petId: number): Promise<Record<string, unknown>> {
    try {
      const response = await fetch(`${this.baseUrl}/pet/${petId}`);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      return await response.json();
    } catch (error) {
      console.error(`Error fetching pet ${petId}:`, error);
      throw error;
    }
  }

  /**
   * Find pets by status.
   * @param status - Pet status (available, pending, sold)
   * @returns List of pets
   */
  async findPetsByStatus(
    status: string = "available"
  ): Promise<Record<string, unknown>[]> {
    try {
      const response = await fetch(
        `${this.baseUrl}/pet/findByStatus?status=${encodeURIComponent(status)}`
      );
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      return await response.json();
    } catch (error) {
      console.error(`Error finding pets by status ${status}:`, error);
      throw error;
    }
  }

  /**
   * Get store inventory.
   * @returns Dictionary mapping status to counts
   */
  async getInventory(): Promise<Record<string, number>> {
    try {
      const response = await fetch(`${this.baseUrl}/store/inventory`);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      return await response.json();
    } catch (error) {
      console.error("Error fetching inventory:", error);
      throw error;
    }
  }
}

/**
 * Main entry point for the MCP server.
 */
async function main() {
  // Create MCP server
  const server = new Server(
    {
      name: "petstore-mcp",
      version: "1.0.0",
    },
    {
      capabilities: {
        tools: {},
      },
    }
  );

  console.log("Created Petstore MCP server");

  // Initialize Petstore service
  const petstoreService = new PetstoreService();

  // Register MCP tools (uncomment after code generation)
  // const petTool = new PetApiMcpToolBase(server);
  // const storeTool = new StoreApiMcpToolBase(server);
  // const userTool = new UserApiMcpToolBase(server);

  console.log("Registered all MCP tools");

  // Example: Manual tool registration (for demonstration)
  server.addTool(
    {
      name: "get_pet_by_id",
      description: "Find pet by ID. Returns a single pet.",
      inputSchema: {
        type: "object",
        properties: {
          petId: {
            type: "integer",
            description: "ID of pet to return",
          },
        },
        required: ["petId"],
      },
    } as Tool,
    async (arguments_: Record<string, unknown>): Promise<TextContent[]> => {
      try {
        const petId = arguments_.petId as number;
        if (!petId) {
          throw new Error("petId is required");
        }

        const result = await petstoreService.getPetById(petId);
        const responseJson = JSON.stringify(result, null, 2);
        return [
          {
            type: "text",
            text: responseJson,
          } as TextContent,
        ];
      } catch (error) {
        const errorResponse = JSON.stringify({
          success: false,
          error: error instanceof Error ? error.message : String(error),
        });
        return [
          {
            type: "text",
            text: errorResponse,
          } as TextContent,
        ];
      }
    }
  );

  server.addTool(
    {
      name: "find_pets_by_status",
      description: "Finds Pets by status. Multiple status values can be provided.",
      inputSchema: {
        type: "object",
        properties: {
          status: {
            type: "string",
            description: "Status values",
            enum: ["available", "pending", "sold"],
            default: "available",
          },
        },
      },
    } as Tool,
    async (arguments_: Record<string, unknown>): Promise<TextContent[]> => {
      try {
        const status = (arguments_.status as string) || "available";
        const result = await petstoreService.findPetsByStatus(status);
        const responseJson = JSON.stringify(result, null, 2);
        return [
          {
            type: "text",
            text: responseJson,
          } as TextContent,
        ];
      } catch (error) {
        const errorResponse = JSON.stringify({
          success: false,
          error: error instanceof Error ? error.message : String(error),
        });
        return [
          {
            type: "text",
            text: errorResponse,
          } as TextContent,
        ];
      }
    }
  );

  server.addTool(
    {
      name: "get_store_inventory",
      description: "Returns pet inventories by status",
      inputSchema: {
        type: "object",
        properties: {},
      },
    } as Tool,
    async (arguments_: Record<string, unknown>): Promise<TextContent[]> => {
      try {
        const result = await petstoreService.getInventory();
        const responseJson = JSON.stringify(result, null, 2);
        return [
          {
            type: "text",
            text: responseJson,
          } as TextContent,
        ];
      } catch (error) {
        const errorResponse = JSON.stringify({
          success: false,
          error: error instanceof Error ? error.message : String(error),
        });
        return [
          {
            type: "text",
            text: errorResponse,
          } as TextContent,
        ];
      }
    }
  );

  console.log("Starting MCP server with stdio transport...");

  // Run server with stdio transport
  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.log("Petstore MCP server is running");
}

/**
 * Run the MCP server.
 *
 * Usage:
 *   node typescript-mcp-example.js
 *
 * Test with MCP Inspector:
 *   npx @modelcontextprotocol/inspector node typescript-mcp-example.js
 */
main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
