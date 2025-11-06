use sqlx::{PgPool, Result};
use crate::models::{User, Sandbox, SandboxWithUser};

// User operations
pub async fn find_or_create_user(
    pool: &PgPool,
    uid: &str,
    nickname: &str,
    image: Option<&str>,
) -> Result<User> {
    let user = sqlx::query_as::<_, User>(
        r#"
        INSERT INTO users (uid, nickname, image, created_at, updated_at)
        VALUES ($1, $2, $3, NOW(), NOW())
        ON CONFLICT (uid) DO UPDATE
        SET nickname = EXCLUDED.nickname,
            image = EXCLUDED.image,
            updated_at = NOW()
        RETURNING *
        "#
    )
    .bind(uid)
    .bind(nickname)
    .bind(image)
    .fetch_one(pool)
    .await?;

    Ok(user)
}

pub async fn find_user_by_id(pool: &PgPool, id: i64) -> Result<Option<User>> {
    let user = sqlx::query_as::<_, User>(
        "SELECT * FROM users WHERE id = $1"
    )
    .bind(id)
    .fetch_optional(pool)
    .await?;

    Ok(user)
}

// Sandbox operations
pub async fn create_sandbox(
    pool: &PgPool,
    id: &str,
    title: &str,
    content: &str,
    mint_version: &str,
    html: &str,
    user_id: i64,
) -> Result<Sandbox> {
    let sandbox = sqlx::query_as::<_, Sandbox>(
        r#"
        INSERT INTO sandboxes (id, title, content, mint_version, html, user_id, created_at, updated_at)
        VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
        RETURNING *
        "#
    )
    .bind(id)
    .bind(title)
    .bind(content)
    .bind(mint_version)
    .bind(html)
    .bind(user_id)
    .fetch_one(pool)
    .await?;

    Ok(sandbox)
}

pub async fn find_sandbox_by_id(pool: &PgPool, id: &str) -> Result<Option<Sandbox>> {
    let sandbox = sqlx::query_as::<_, Sandbox>(
        "SELECT * FROM sandboxes WHERE id = $1"
    )
    .bind(id)
    .fetch_optional(pool)
    .await?;

    Ok(sandbox)
}

pub async fn find_sandbox_with_user(pool: &PgPool, id: &str) -> Result<Option<SandboxWithUser>> {
    let result = sqlx::query_as::<_, (Sandbox, User)>(
        r#"
        SELECT s.*, u.*
        FROM sandboxes s
        JOIN users u ON s.user_id = u.id
        WHERE s.id = $1
        "#
    )
    .bind(id)
    .fetch_optional(pool)
    .await?;

    Ok(result.map(|(sandbox, user)| sandbox.with_user(user)))
}

pub async fn list_user_sandboxes(pool: &PgPool, user_id: i64) -> Result<Vec<SandboxWithUser>> {
    let results = sqlx::query_as::<_, (Sandbox, User)>(
        r#"
        SELECT s.*, u.*
        FROM sandboxes s
        JOIN users u ON s.user_id = u.id
        WHERE s.user_id = $1
        ORDER BY s.title
        "#
    )
    .bind(user_id)
    .fetch_all(pool)
    .await?;

    Ok(results.into_iter()
        .map(|(sandbox, user)| sandbox.with_user(user))
        .collect())
}

pub async fn list_recent_sandboxes(pool: &PgPool, limit: i64) -> Result<Vec<SandboxWithUser>> {
    let results = sqlx::query_as::<_, (Sandbox, User)>(
        r#"
        SELECT s.*, u.*
        FROM sandboxes s
        JOIN users u ON s.user_id = u.id
        ORDER BY s.updated_at DESC
        LIMIT $1
        "#
    )
    .bind(limit)
    .fetch_all(pool)
    .await?;

    Ok(results.into_iter()
        .map(|(sandbox, user)| sandbox.with_user(user))
        .collect())
}

pub async fn update_sandbox(
    pool: &PgPool,
    id: &str,
    title: Option<&str>,
    content: Option<&str>,
    mint_version: Option<&str>,
    html: Option<&str>,
) -> Result<Sandbox> {
    // Build dynamic update query
    let mut query = String::from("UPDATE sandboxes SET updated_at = NOW()");
    let mut params: Vec<String> = vec![];
    let mut param_count = 1;

    if let Some(_) = title {
        params.push(format!("title = ${}", param_count));
        param_count += 1;
    }
    if let Some(_) = content {
        params.push(format!("content = ${}", param_count));
        param_count += 1;
    }
    if let Some(_) = mint_version {
        params.push(format!("mint_version = ${}", param_count));
        param_count += 1;
    }
    if let Some(_) = html {
        params.push(format!("html = ${}", param_count));
        param_count += 1;
    }

    if !params.is_empty() {
        query.push_str(", ");
        query.push_str(&params.join(", "));
    }

    query.push_str(&format!(" WHERE id = ${} RETURNING *", param_count));

    let mut q = sqlx::query_as::<_, Sandbox>(&query);

    if let Some(t) = title {
        q = q.bind(t);
    }
    if let Some(c) = content {
        q = q.bind(c);
    }
    if let Some(mv) = mint_version {
        q = q.bind(mv);
    }
    if let Some(h) = html {
        q = q.bind(h);
    }

    q = q.bind(id);

    let sandbox = q.fetch_one(pool).await?;
    Ok(sandbox)
}

pub async fn delete_sandbox(pool: &PgPool, id: &str) -> Result<Sandbox> {
    let sandbox = sqlx::query_as::<_, Sandbox>(
        "DELETE FROM sandboxes WHERE id = $1 RETURNING *"
    )
    .bind(id)
    .fetch_one(pool)
    .await?;

    Ok(sandbox)
}
