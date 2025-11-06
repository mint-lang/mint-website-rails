use oauth2::{
    AuthUrl, AuthorizationCode, ClientId, ClientSecret, CsrfToken, RedirectUrl,
    Scope, TokenResponse, TokenUrl, basic::BasicClient,
};
use serde::{Deserialize, Serialize};
use crate::config::Config;

#[derive(Debug, Serialize, Deserialize)]
pub struct GitHubUser {
    pub id: u64,
    pub login: String,
    pub avatar_url: Option<String>,
}

pub fn create_oauth_client(config: &Config) -> anyhow::Result<BasicClient> {
    let client = BasicClient::new(
        ClientId::new(config.github_client_id.clone()),
        Some(ClientSecret::new(config.github_client_secret.clone())),
        AuthUrl::new("https://github.com/login/oauth/authorize".to_string())?,
        Some(TokenUrl::new("https://github.com/login/oauth/access_token".to_string())?),
    )
    .set_redirect_uri(RedirectUrl::new(config.callback_url())?);

    Ok(client)
}

pub fn get_authorization_url(client: &BasicClient) -> (String, CsrfToken) {
    let (auth_url, csrf_token) = client
        .authorize_url(CsrfToken::new_random)
        .add_scope(Scope::new("read:user".to_string()))
        .url();

    (auth_url.to_string(), csrf_token)
}

pub async fn exchange_code(
    client: &BasicClient,
    code: String,
) -> anyhow::Result<String> {
    let token = client
        .exchange_code(AuthorizationCode::new(code))
        .request_async(oauth2::reqwest::async_http_client)
        .await?;

    Ok(token.access_token().secret().to_string())
}

pub async fn get_github_user(access_token: &str) -> anyhow::Result<GitHubUser> {
    let client = reqwest::Client::new();
    let user = client
        .get("https://api.github.com/user")
        .header("Authorization", format!("Bearer {}", access_token))
        .header("User-Agent", "mint-sandbox-api")
        .send()
        .await?
        .json::<GitHubUser>()
        .await?;

    Ok(user)
}
