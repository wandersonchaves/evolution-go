# Evolution Go - Project Context

Evolution Go is a high-performance WhatsApp API built in Go, part of the Evolution ecosystem. It provides a robust, lightweight solution for WhatsApp integration using the [whatsmeow](https://github.com/tulir/whatsmeow) library.

## Project Overview

- **Core Technology:** Go 1.25+
- **HTTP Framework:** [Gin](https://github.com/gin-gonic/gin)
- **WhatsApp Library:** [whatsmeow](https://github.com/tulir/whatsmeow) (cloned locally in `whatsmeow-lib/`)
- **Persistence:** PostgreSQL (via GORM), optional message storage.
- **Events/Real-time:** Support for Webhooks, WebSockets, RabbitMQ (AMQP), and NATS.
- **Storage:** MinIO/S3 for media files.
- **Documentation:** Swagger/OpenAPI.
- **License:** Apache 2.0. Requires activation for full functionality.

## Architecture & Directory Structure

The project follows a standard Go project layout:

- `cmd/evolution-go/`: Application entry point (`main.go`).
- `pkg/`: Core application logic organized by domain.
    - `core/`: License management, gateway middleware, and core database logic.
    - `instance/`: WhatsApp instance lifecycle management (create, connect, disconnect).
    - `message/`: Message handling and repository logic.
    - `sendMessage/`: Services and handlers for sending various types of messages.
    - `routes/`: Centralized route definitions and Gin router setup.
    - `events/`: Event producers for different protocols (AMQP, NATS, Webhook, WebSocket).
    - `config/`: Configuration loading from environment variables.
    - `middleware/`: Authentication and JID validation logic.
    - `storage/`: Media storage abstractions (currently supports MinIO).
    - `whatsmeow/`: Integration layer with the `whatsmeow` library.
- `whatsmeow-lib/`: Local copy/fork of the `whatsmeow` library, referenced via `go.mod` replace directive.
- `docs/`: Swagger documentation files.
- `manager/`: React-based management interface (served at `/manager`).
- `docker/`: Docker Compose examples and SQL initialization scripts.

## Development Workflows

### Prerequisites
- Go 1.25+
- PostgreSQL
- (Optional) RabbitMQ, NATS, MinIO

### Key Commands (via Makefile)

- **Setup Environment:** `make setup` (Installs dependencies and generates Swagger)
- **Development Mode:** `make dev` (Runs with `.env` loading and `-dev` flag)
- **Build:** `make build` (Outputs to `build/evolution-go`)
- **Test:** `make test` (Runs all tests)
- **Swagger:** `make swagger` (Re-generates documentation)
- **Docker:** `make docker-build` and `make docker-run`

### Configuration
Configuration is managed via environment variables. See `.env.example` for a complete list.
- `GLOBAL_API_KEY`: Required for API authentication.
- `POSTGRES_USERS_DB`: Connection string for the main database.
- `SERVER_PORT`: Port the API will listen on (default: 8080).

## Development Conventions

1.  **Dependency Injection:** Services and handlers are initialized in `cmd/evolution-go/main.go` and injected where needed.
2.  **Middleware:**
    - Use `auth_middleware` for API key verification.
    - Use `jidValidationMiddleware` for validating WhatsApp IDs (JIDs) in request parameters.
3.  **Routes:** New endpoints should be added in `pkg/routes/routes.go` within the appropriate group.
4.  **Error Handling:** Follow idiomatic Go error handling. Log errors using the `pkg/logger` wrapper.
5.  **Events:** When adding new events, ensure they are implemented for all supported producers (Webhook, WS, AMQP, NATS) if they are global events.
6.  **Whatsmeow Integration:** The `pkg/whatsmeow/service` is the primary interface for interacting with the WhatsApp protocol.

## Critical Notes

- **License Activation:** The API returns `503 Service Unavailable` until a valid license is activated via the `/manager` interface or core routes.
- **Whatsmeow Source:** Do not modify `whatsmeow-lib/` unless absolutely necessary, as it is a mirrored dependency.
- **Database Migrations:** The application uses GORM's `AutoMigrate` for schema updates on startup.
