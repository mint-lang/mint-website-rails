use axum::{
    extract::{Query, State},
    response::{IntoResponse, Redirect},
    Json,
};
use serde::Deserialize;
use tower_sessions::Session;

use crate::{
    db,
    error::AppError,
    middleware::{get_session_user_id, set_session_user_id, clear_session},
    oauth::{create_oauth_client, exchange_code, get_authorization_url, get_github_user},
};

use super::AppState;

#[derive(Deserialize)]
pub struct AuthCallback {
    code: String,
    state: Option<String>,
}

/// GET /auth/github
/// Initiates GitHub OAuth flow
pub async fn github_login(
    State(state): State<AppState>,
) -> Result<impl IntoResponse, AppError> {
    let client = create_oauth_client(&state.config)?;
    let (auth_url, _csrf_token) = get_authorization_url(&client);

    Ok(Redirect::to(&auth_url))
}

/// GET /auth/github/callback
/// Handles GitHub OAuth callback
pub async fn github_callback(
    State(state): State<AppState>,
    Query(params): Query<AuthCallback>,
    session: Session,
) -> Result<impl IntoResponse, AppError> {
    // Exchange code for access token
    let client = create_oauth_client(&state.config)?;
    let access_token = exchange_code(&client, params.code).await?;

    // Get user info from GitHub
    let gh_user = get_github_user(&access_token).await?;

    // Find or create user in database
    let user = db::find_or_create_user(
        &state.db,
        &gh_user.id.to_string(),
        &gh_user.login,
        gh_user.avatar_url.as_deref(),
    )
    .await?;

    // Set session
    set_session_user_id(&session, user.id).await?;

    // Redirect to sandbox URL
    Ok(Redirect::to(&state.config.sandbox_url))
}

/// GET /sandbox/logout
/// Logs out the current user
pub async fn logout(
    session: Session,
) -> Result<impl IntoResponse, AppError> {
    clear_session(&session).await?;
    Ok(Json(serde_json::json!({ "status": "ok" })))
}

/// GET /sandbox/user
/// Gets current user info
pub async fn get_user(
    State(state): State<AppState>,
    session: Session,
) -> Result<impl IntoResponse, AppError> {
    let user_id = get_session_user_id(&session).await?;

    let user = db::find_user_by_id(&state.db, user_id)
        .await?
        .ok_or(AppError::Unauthorized)?;

    Ok(Json(user))
}
