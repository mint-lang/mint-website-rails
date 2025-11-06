mod config;
mod models;
mod handlers;
mod middleware;
mod db;
mod oauth;
mod error;

use axum::{
    Router,
    routing::{get, post, patch, delete},
};
use tower_http::cors::{CorsLayer, Any};
use tower_http::trace::TraceLayer;
use tower_sessions::{SessionManagerLayer, Expiry};
use tower_sessions_sqlx_store::PostgresStore;
use sqlx::postgres::PgPoolOptions;
use std::time::Duration;

use crate::config::Config;
use crate::handlers::*;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt::init();

    // Load configuration
    let config = Config::from_env()?;
    tracing::info!("Starting Mint Sandbox API on {}", config.server_addr());

    // Setup database connection pool
    let db_pool = PgPoolOptions::new()
        .max_connections(5)
        .connect(&config.database_url)
        .await?;

    // Run migrations
    sqlx::migrate!("./migrations")
        .run(&db_pool)
        .await?;

    // Setup session store
    let session_store = PostgresStore::new(db_pool.clone());
    session_store.migrate().await?;

    let session_layer = SessionManagerLayer::new(session_store)
        .with_expiry(Expiry::OnInactivity(Duration::from_secs(86400 * 30))); // 30 days

    // Setup CORS
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any)
        .allow_credentials(true);

    // Create application state
    let state = crate::handlers::AppState {
        db: db_pool,
        config: config.clone(),
    };

    // Build routes
    let app = Router::new()
        // Auth routes
        .route("/auth/github", get(auth::github_login))
        .route("/auth/github/callback", get(auth::github_callback))
        .route("/sandbox/logout", get(auth::logout))
        .route("/sandbox/user", get(auth::get_user))
        // Sandbox routes
        .route("/sandbox", get(sandbox::list_user_sandboxes).post(sandbox::create_sandbox))
        .route("/sandbox/recent", get(sandbox::list_recent_sandboxes))
        .route("/sandbox/:id",
            get(sandbox::get_sandbox)
            .patch(sandbox::update_sandbox)
            .delete(sandbox::delete_sandbox))
        .route("/sandbox/:id/fork", post(sandbox::fork_sandbox))
        .with_state(state)
        .layer(session_layer)
        .layer(cors)
        .layer(TraceLayer::new_for_http());

    // Start server
    let listener = tokio::net::TcpListener::bind(&config.server_addr())
        .await?;

    tracing::info!("Server listening on {}", config.server_addr());
    axum::serve(listener, app).await?;

    Ok(())
}
