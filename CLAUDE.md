# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EventTapKit is a Swift package that provides a wrapper around macOS's CGEventTap API for monitoring and modifying system events. It uses protocol-oriented design with dependency injection for testability.

## Build Commands

This is a Swift Package Manager project. Always use these commands from the project root:

```bash
# Build the package
swift build

# Run all tests
swift test

# Run specific test
swift test --filter TestName

# Clean build artifacts
swift package clean
```

## Architecture

### Core Design Patterns

1. **Protocol-Based Architecture**: `MachPortProtocol` defines the interface, with `MachPortLive` (production) and `MachPortMock` (testing) implementations.

2. **Generic Manager**: `EventTapManager<T: MachPortProtocol>` handles event tap lifecycle and is generic over the MachPort implementation for testability.

3. **Dependency Injection**: Uses Point-Free's Dependencies library for the public API (`EventTapManagerClient`).

### Key Components

- **MachPortProtocol**: Core protocol defining event tap operations
- **EventTapManager**: Internal generic manager handling tap lifecycle, state, and callbacks
- **EventTapManagerClient**: Public API using Dependencies for injection
- **MachPortLive**: Wraps CGEvent APIs for actual event tap functionality
- **MachPortMock**: Test double tracking method calls and providing controllable behavior

### Important Implementation Details

- Event taps are created disabled and must be explicitly enabled
- The manager handles tap timeout scenarios and user input disabled states
- Callbacks use `@Sendable` closures for thread safety
- The public API separates internal implementation details from the client interface

## Testing Guidelines

When writing tests:
- Use `MachPortMock` to verify event tap interactions
- Test both success and failure scenarios
- Verify proper cleanup when taps are stopped
- Check that callbacks are invoked correctly
- Ensure proper state transitions (disabled → enabled → disabled)

## Development Notes

- This is a macOS-only package (minimum macOS 12.0)
- Requires Swift 5.10 or later
- Dependencies are managed via Swift Package Manager
- The project uses Point-Free's Dependencies library - familiarize yourself with its patterns when modifying the public API