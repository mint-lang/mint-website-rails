use axum::{
    extract::{Path, State},
    response::IntoResponse,
    Json,
};
use tower_sessions::Session;

use crate::{
    db,
    error::AppError,
    middleware::get_session_user_id,
    models::{CreateSandboxRequest, UpdateSandboxRequest, DEFAULT_SANDBOX, DEFAULT_HTML},
};

use super::AppState;

fn generate_sandbox_id() -> String {
    use base64::{Engine as _, engine::general_purpose};
    use rand::Rng;

    let mut bytes = [0u8; 10];
    rand::thread_rng().fill(&mut bytes);
    general_purpose::URL_SAFE_NO_PAD.encode(&bytes)
}

/// GET /sandbox
/// Lists all sandboxes for the authenticated user
pub async fn list_user_sandboxes(
    State(state): State<AppState>,
    session: Session,
) -> Result<impl IntoResponse, AppError> {
    let user_id = get_session_user_id(&session).await?;
    let sandboxes = db::list_user_sandboxes(&state.db, user_id).await?;

    Ok(Json(sandboxes))
}

/// GET /sandbox/recent
/// Lists 20 most recently updated sandboxes (no auth required)
pub async fn list_recent_sandboxes(
    State(state): State<AppState>,
) -> Result<impl IntoResponse, AppError> {
    let sandboxes = db::list_recent_sandboxes(&state.db, 20).await?;

    Ok(Json(sandboxes))
}

/// GET /sandbox/:id
/// Gets a specific sandbox (no auth required)
pub async fn get_sandbox(
    State(state): State<AppState>,
    Path(id): Path<String>,
) -> Result<impl IntoResponse, AppError> {
    let sandbox = db::find_sandbox_with_user(&state.db, &id)
        .await?
        .ok_or(AppError::NotFound)?;

    Ok(Json(sandbox))
}

/// POST /sandbox
/// Creates a new sandbox
pub async fn create_sandbox(
    State(state): State<AppState>,
    session: Session,
    Json(payload): Json<CreateSandboxRequest>,
) -> Result<impl IntoResponse, AppError> {
    let user_id = get_session_user_id(&session).await?;

    let sandbox_id = generate_sandbox_id();
    let title = payload.title.unwrap_or_else(|| "My Sandbox".to_string());
    let content = payload.content.unwrap_or_else(|| DEFAULT_SANDBOX.to_string());
    let mint_version = payload.mint_version.unwrap_or_else(|| "0.19.0".to_string());

    let sandbox = db::create_sandbox(
        &state.db,
        &sandbox_id,
        &title,
        &content,
        &mint_version,
        DEFAULT_HTML,
        user_id,
    )
    .await?;

    // Get user info
    let user = db::find_user_by_id(&state.db, user_id)
        .await?
        .ok_or(AppError::Internal(anyhow::anyhow!("User not found")))?;

    Ok(Json(sandbox.with_user(user)))
}

/// PATCH /sandbox/:id
/// Updates a sandbox
pub async fn update_sandbox(
    State(state): State<AppState>,
    session: Session,
    Path(id): Path<String>,
    Json(payload): Json<UpdateSandboxRequest>,
) -> Result<impl IntoResponse, AppError> {
    let user_id = get_session_user_id(&session).await?;

    // Check if sandbox exists and user owns it
    let existing = db::find_sandbox_by_id(&state.db, &id)
        .await?
        .ok_or(AppError::NotFound)?;

    if existing.user_id != user_id {
        return Err(AppError::Forbidden);
    }

    // Update sandbox
    let sandbox = db::update_sandbox(
        &state.db,
        &id,
        payload.title.as_deref(),
        payload.content.as_deref(),
        payload.mint_version.as_deref(),
        None, // html - would be compiled in a real implementation
    )
    .await?;

    // Get user info
    let user = db::find_user_by_id(&state.db, user_id)
        .await?
        .ok_or(AppError::Internal(anyhow::anyhow!("User not found")))?;

    Ok(Json(sandbox.with_user(user)))
}

/// DELETE /sandbox/:id
/// Deletes a sandbox
pub async fn delete_sandbox(
    State(state): State<AppState>,
    session: Session,
    Path(id): Path<String>,
) -> Result<impl IntoResponse, AppError> {
    let user_id = get_session_user_id(&session).await?;

    // Check if sandbox exists and user owns it
    let existing = db::find_sandbox_by_id(&state.db, &id)
        .await?
        .ok_or(AppError::NotFound)?;

    if existing.user_id != user_id {
        return Err(AppError::Forbidden);
    }

    // Delete sandbox
    let sandbox = db::delete_sandbox(&state.db, &id).await?;

    // Get user info
    let user = db::find_user_by_id(&state.db, user_id)
        .await?
        .ok_or(AppError::Internal(anyhow::anyhow!("User not found")))?;

    Ok(Json(sandbox.with_user(user)))
}

/// POST /sandbox/:id/fork
/// Forks a sandbox
pub async fn fork_sandbox(
    State(state): State<AppState>,
    session: Session,
    Path(id): Path<String>,
) -> Result<impl IntoResponse, AppError> {
    let user_id = get_session_user_id(&session).await?;

    // Get original sandbox
    let original = db::find_sandbox_by_id(&state.db, &id)
        .await?
        .ok_or(AppError::NotFound)?;

    // Create forked sandbox
    let new_id = generate_sandbox_id();
    let forked = db::create_sandbox(
        &state.db,
        &new_id,
        &original.title,
        &original.content,
        &original.mint_version,
        original.html.as_deref().unwrap_or(DEFAULT_HTML),
        user_id,
    )
    .await?;

    // Get user info
    let user = db::find_user_by_id(&state.db, user_id)
        .await?
        .ok_or(AppError::Internal(anyhow::anyhow!("User not found")))?;

    Ok(Json(forked.with_user(user)))
}
