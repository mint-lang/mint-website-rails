# Mint Sandbox API - Rust Implementation

A Rust-based implementation of the Mint Sandbox API, providing GitHub authentication and sandbox management functionality.

## Features

- **GitHub OAuth Authentication**: Secure user authentication via GitHub OAuth 2.0
- **Sandbox Management**:
  - Create new sandboxes with Mint code
  - Update existing sandboxes
  - Delete owned sandboxes
  - Fork any public sandbox
  - List user sandboxes
  - List recent sandboxes across all users
- **Session Management**: Secure cookie-based sessions with PostgreSQL storage
- **RESTful API**: Clean REST endpoints with JSON responses

## Tech Stack

- **Framework**: Axum 0.7 (High-performance async web framework)
- **Runtime**: Tokio (Async runtime)
- **Database**: PostgreSQL with SQLx (Compile-time checked queries)
- **OAuth**: OAuth2 crate for GitHub authentication
- **Sessions**: Tower-sessions with PostgreSQL store

## Prerequisites

- Rust 1.70+ (stable)
- PostgreSQL 12+
- GitHub OAuth Application (for authentication)

## Setup

### 1. Clone and Navigate

```bash
cd rust
```

### 2. Database Setup

Create a PostgreSQL database:

```bash
createdb mint_website_development
```

### 3. Configuration

Copy the example environment file and configure:

```bash
cp .env.example .env
```

Edit `.env` with your settings:

```env
DATABASE_URL=postgres://localhost/mint_website_development
GITHUB_KEY=your_github_client_id
GITHUB_SECRET=your_github_client_secret
SANDBOX_URL=http://localhost:3000
HOST=127.0.0.1
PORT=8080
```

### 4. GitHub OAuth Application

1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Create a new OAuth App with:
   - **Authorization callback URL**: `http://127.0.0.1:8080/auth/github/callback`
3. Copy the Client ID and Client Secret to your `.env` file

### 5. Build and Run

```bash
# Build the project
cargo build --release

# Run migrations and start server
cargo run --release
```

The server will start on `http://127.0.0.1:8080`

## API Endpoints

### Authentication

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/auth/github` | No | Initiate GitHub OAuth login |
| GET | `/auth/github/callback` | No | GitHub OAuth callback |
| GET | `/sandbox/logout` | Yes | Logout current user |
| GET | `/sandbox/user` | Yes | Get current user info |

### Sandboxes

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/sandbox` | Yes | List user's sandboxes |
| POST | `/sandbox` | Yes | Create new sandbox |
| GET | `/sandbox/recent` | No | List 20 recent sandboxes |
| GET | `/sandbox/:id` | No | Get specific sandbox |
| PATCH | `/sandbox/:id` | Yes | Update sandbox |
| DELETE | `/sandbox/:id` | Yes | Delete sandbox (owner only) |
| POST | `/sandbox/:id/fork` | Yes | Fork a sandbox |

### Example Requests

#### Create Sandbox

```bash
curl -X POST http://localhost:8080/sandbox \
  -H "Content-Type: application/json" \
  -b cookies.txt \
  -d '{
    "title": "My First Sandbox",
    "content": "component Main {\n  fun render : Html {\n    <div>\"Hello World!\"</div>\n  }\n}",
    "mint_version": "0.19.0"
  }'
```

#### Update Sandbox

```bash
curl -X PATCH http://localhost:8080/sandbox/abc123 \
  -H "Content-Type: application/json" \
  -b cookies.txt \
  -d '{
    "title": "Updated Title",
    "content": "component Main {\n  fun render : Html {\n    <div>\"Updated!\"</div>\n  }\n}"
  }'
```

#### List User Sandboxes

```bash
curl http://localhost:8080/sandbox -b cookies.txt
```

#### Fork Sandbox

```bash
curl -X POST http://localhost:8080/sandbox/abc123/fork -b cookies.txt
```

## Database Schema

### Users Table

```sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    uid VARCHAR(255) NOT NULL UNIQUE,
    nickname VARCHAR(255) NOT NULL,
    image VARCHAR(512),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);
```

### Sandboxes Table

```sql
CREATE TABLE sandboxes (
    id VARCHAR(255) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    html TEXT,
    mint_version VARCHAR(50) NOT NULL,
    user_id BIGINT NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);
```

## Project Structure

```
rust/
├── Cargo.toml              # Dependencies and project config
├── src/
│   ├── main.rs            # Application entry point
│   ├── config.rs          # Configuration management
│   ├── models.rs          # Data models
│   ├── db.rs              # Database operations
│   ├── oauth.rs           # GitHub OAuth implementation
│   ├── error.rs           # Error handling
│   ├── middleware.rs      # Session middleware
│   └── handlers/
│       ├── mod.rs         # Handler module
│       ├── auth.rs        # Authentication endpoints
│       └── sandbox.rs     # Sandbox CRUD endpoints
├── migrations/            # SQL migrations
│   ├── 20240101000000_create_users.sql
│   └── 20240101000001_create_sandboxes.sql
└── README.md
```

## Development

### Running Tests

```bash
cargo test
```

### Checking Code

```bash
# Check compilation
cargo check

# Run linter
cargo clippy

# Format code
cargo fmt
```

### Database Migrations

Migrations are automatically run on startup. To create a new migration:

```bash
# Create migration file in migrations/ directory
touch migrations/$(date +%Y%m%d%H%M%S)_description.sql
```

## Differences from Rails Version

This Rust implementation focuses on core functionality:

**Included:**
- GitHub OAuth authentication
- Sandbox CRUD operations
- Session management
- User management

**Excluded (as per requirements):**
- Mint code compilation
- Code formatting
- Screenshot generation
- Package management
- AWS S3 integration
- Background job processing

## Security Notes

- Sessions are stored in PostgreSQL with automatic expiration
- CSRF protection is handled by OAuth state parameter
- SQL injection protection via SQLx compile-time checked queries
- Passwords are never stored (GitHub OAuth only)

## Performance

- Async/await throughout for high concurrency
- Connection pooling for database efficiency
- Compile-time query verification prevents runtime SQL errors
- Zero-cost abstractions from Rust

## License

Same as parent project.

## Contributing

1. Follow Rust standard style guide (`cargo fmt`)
2. Ensure `cargo clippy` passes
3. Add tests for new functionality
4. Update this README for API changes
