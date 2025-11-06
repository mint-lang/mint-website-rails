use tower_sessions::Session;
use crate::models::User;
use crate::error::AppError;

pub const SESSION_USER_ID: &str = "user_id";

pub async fn get_session_user_id(session: &Session) -> Result<i64, AppError> {
    session
        .get::<i64>(SESSION_USER_ID)
        .await
        .map_err(|_| AppError::Internal(anyhow::anyhow!("Failed to read session")))?
        .ok_or(AppError::Unauthorized)
}

pub async fn set_session_user_id(session: &Session, user_id: i64) -> Result<(), AppError> {
    session
        .insert(SESSION_USER_ID, user_id)
        .await
        .map_err(|_| AppError::Internal(anyhow::anyhow!("Failed to write session")))
}

pub async fn clear_session(session: &Session) -> Result<(), AppError> {
    session
        .flush()
        .await
        .map_err(|_| AppError::Internal(anyhow::anyhow!("Failed to clear session")))
}
