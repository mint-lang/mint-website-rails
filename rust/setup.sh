#!/bin/bash
set -e

echo "🚀 Mint Sandbox API Setup"
echo ""

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "❌ Rust is not installed. Please install from https://rustup.rs/"
    exit 1
fi

echo "✅ Rust found: $(rustc --version)"

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL is not installed. Please install PostgreSQL 12+"
    exit 1
fi

echo "✅ PostgreSQL found"

# Check for .env file
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example"
    cp .env.example .env
    echo "⚠️  Please edit .env with your GitHub OAuth credentials"
    exit 0
fi

echo "✅ .env file exists"

# Read DATABASE_URL from .env
export $(cat .env | grep DATABASE_URL | xargs)

# Create database if it doesn't exist
DB_NAME=$(echo $DATABASE_URL | sed 's/.*\///')
if psql -lqt | cut -d \| -f 1 | grep -qw $DB_NAME; then
    echo "✅ Database '$DB_NAME' exists"
else
    echo "📝 Creating database '$DB_NAME'"
    createdb $DB_NAME
    echo "✅ Database created"
fi

# Build the project
echo "🔨 Building project..."
cargo build

echo ""
echo "✅ Setup complete!"
echo ""
echo "To run the server:"
echo "  cargo run"
echo ""
echo "Or with Docker:"
echo "  docker-compose up"
