#!/usr/bin/env python3
"""
Example Python MCP Server using generated Petstore API tools.

This example demonstrates how to use the generated MCP tools with
a Python MCP server implementation.
"""

import asyncio
import logging
from typing import Any, Dict
import httpx

from mcp.server import Server
from mcp.server.stdio import stdio_server

# Import generated MCP tools (after generation)
# from petstore_mcp.api.pet_api import PetApiMcpToolBase
# from petstore_mcp.api.store_api import StoreApiMcpToolBase
# from petstore_mcp.api.user_api import UserApiMcpToolBase

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class PetstoreService:
    """
    Service implementation that communicates with Petstore API.

    This service acts as a bridge between MCP tools and the Petstore REST API via HTTP.
    """

    def __init__(self, api_base_url: str = "https://petstore3.swagger.io/api/v3"):
        """
        Initialize Petstore service.

        Args:
            api_base_url: Base URL of Petstore API
        """
        self.base_url = api_base_url
        self.client = httpx.AsyncClient(base_url=api_base_url, timeout=10.0)
        logger.info(f"Initialized Petstore service: {api_base_url}")

    async def get_pet_by_id(self, pet_id: int) -> Dict[str, Any]:
        """
        Get pet by ID from Petstore API.

        Args:
            pet_id: Pet ID to fetch

        Returns:
            Dictionary containing pet information
        """
        try:
            response = await self.client.get(f"/pet/{pet_id}")
            response.raise_for_status()
            return response.json()
        except httpx.HTTPError as e:
            logger.error(f"Error fetching pet {pet_id}: {e}")
            raise

    async def find_pets_by_status(self, status: str = "available") -> list[Dict[str, Any]]:
        """
        Find pets by status.

        Args:
            status: Pet status (available, pending, sold)

        Returns:
            List of pets
        """
        try:
            response = await self.client.get(f"/pet/findByStatus", params={"status": status})
            response.raise_for_status()
            return response.json()
        except httpx.HTTPError as e:
            logger.error(f"Error finding pets by status {status}: {e}")
            raise

    async def get_inventory(self) -> Dict[str, int]:
        """
        Get store inventory.

        Returns:
            Dictionary mapping status to counts
        """
        try:
            response = await self.client.get("/store/inventory")
            response.raise_for_status()
            return response.json()
        except httpx.HTTPError as e:
            logger.error(f"Error fetching inventory: {e}")
            raise

    async def close(self):
        """Close HTTP client."""
        await self.client.aclose()


async def main():
    """Main entry point for the MCP server."""

    # Create MCP server
    server = Server("petstore-mcp")
    logger.info("Created Petstore MCP server")

    # Initialize Petstore service
    petstore_service = PetstoreService()

    # Register MCP tools (uncomment after code generation)
    # pet_tool = PetApiMcpToolBase(server)
    # store_tool = StoreApiMcpToolBase(server)
    # user_tool = UserApiMcpToolBase(server)

    logger.info("Registered all MCP tools")

    # Example: Manual tool registration (for demonstration)
    from mcp.types import Tool, TextContent
    import json

    @server.call_tool()
    async def get_pet_by_id(arguments: Dict[str, Any]) -> list[TextContent]:
        """Get pet by ID from Petstore."""
        try:
            pet_id = arguments.get("petId")
            if not pet_id:
                raise ValueError("petId is required")

            result = await petstore_service.get_pet_by_id(int(pet_id))
            response_json = json.dumps(result, indent=2)
            return [TextContent(type="text", text=response_json)]
        except Exception as e:
            error_response = json.dumps({
                "success": False,
                "error": str(e)
            })
            return [TextContent(type="text", text=error_response)]

    @server.call_tool()
    async def find_pets_by_status(arguments: Dict[str, Any]) -> list[TextContent]:
        """Find pets by status."""
        try:
            status = arguments.get("status", "available")
            result = await petstore_service.find_pets_by_status(status)
            response_json = json.dumps(result, indent=2)
            return [TextContent(type="text", text=response_json)]
        except Exception as e:
            error_response = json.dumps({
                "success": False,
                "error": str(e)
            })
            return [TextContent(type="text", text=error_response)]

    @server.call_tool()
    async def get_store_inventory(arguments: Dict[str, Any]) -> list[TextContent]:
        """Get store inventory."""
        try:
            result = await petstore_service.get_inventory()
            response_json = json.dumps(result, indent=2)
            return [TextContent(type="text", text=response_json)]
        except Exception as e:
            error_response = json.dumps({
                "success": False,
                "error": str(e)
            })
            return [TextContent(type="text", text=error_response)]

    # Register tools with server
    server.add_tool(
        Tool(
            name="get_pet_by_id",
            description="Find pet by ID. Returns a single pet.",
            inputSchema={
                "type": "object",
                "properties": {
                    "petId": {
                        "type": "integer",
                        "description": "ID of pet to return"
                    }
                },
                "required": ["petId"]
            }
        ),
        get_pet_by_id
    )

    server.add_tool(
        Tool(
            name="find_pets_by_status",
            description="Finds Pets by status. Multiple status values can be provided.",
            inputSchema={
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "description": "Status values",
                        "enum": ["available", "pending", "sold"],
                        "default": "available"
                    }
                }
            }
        ),
        find_pets_by_status
    )

    server.add_tool(
        Tool(
            name="get_store_inventory",
            description="Returns pet inventories by status",
            inputSchema={
                "type": "object",
                "properties": {}
            }
        ),
        get_store_inventory
    )

    logger.info("Starting MCP server with stdio transport...")

    try:
        # Run server with stdio transport
        async with stdio_server() as (read_stream, write_stream):
            await server.run(
                read_stream,
                write_stream,
                server.create_initialization_options()
            )
    finally:
        await petstore_service.close()


if __name__ == "__main__":
    """
    Run the MCP server.

    Usage:
        python examples/python-mcp-example.py

    Test with MCP Inspector:
        npx @modelcontextprotocol/inspector python examples/python-mcp-example.py
    """
    asyncio.run(main())
