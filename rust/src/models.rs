use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::FromRow;

#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct User {
    pub id: i64,
    pub uid: String,
    pub nickname: String,
    pub image: Option<String>,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize, FromRow)]
pub struct Sandbox {
    pub id: String,
    pub title: String,
    pub content: String,
    pub html: Option<String>,
    pub mint_version: String,
    pub user_id: i64,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SandboxWithUser {
    pub id: String,
    pub title: String,
    pub content: String,
    pub mint_version: String,
    pub user_id: i64,
    pub created_at: DateTime<Utc>,
    pub updated_at: DateTime<Utc>,
    pub user: UserInfo,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserInfo {
    pub id: i64,
    pub nickname: String,
    pub image: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct CreateSandboxRequest {
    pub title: Option<String>,
    pub content: Option<String>,
    pub mint_version: Option<String>,
}

#[derive(Debug, Deserialize)]
pub struct UpdateSandboxRequest {
    pub title: Option<String>,
    pub content: Option<String>,
    pub mint_version: Option<String>,
}

impl From<User> for UserInfo {
    fn from(user: User) -> Self {
        Self {
            id: user.id,
            nickname: user.nickname,
            image: user.image,
        }
    }
}

impl Sandbox {
    pub fn with_user(self, user: User) -> SandboxWithUser {
        SandboxWithUser {
            id: self.id,
            title: self.title,
            content: self.content,
            mint_version: self.mint_version,
            user_id: self.user_id,
            created_at: self.created_at,
            updated_at: self.updated_at,
            user: user.into(),
        }
    }
}

pub const DEFAULT_SANDBOX: &str = r#"component Main {
  fun render : Html {
    <div>"Hello World!"</div>
  }
}"#;

pub const DEFAULT_HTML: &str = r#"<!DOCTYPE html><html><head></head><body><div>Hello World!</div></body></html>"#;
