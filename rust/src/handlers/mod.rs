pub mod auth;
pub mod sandbox;

use sqlx::PgPool;
use crate::config::Config;

#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
    pub config: Config,
}
