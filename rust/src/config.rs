use std::env;

#[derive(Clone, Debug)]
pub struct Config {
    pub database_url: String,
    pub github_client_id: String,
    pub github_client_secret: String,
    pub sandbox_url: String,
    pub host: String,
    pub port: u16,
}

impl Config {
    pub fn from_env() -> anyhow::Result<Self> {
        dotenvy::dotenv().ok();

        Ok(Self {
            database_url: env::var("DATABASE_URL")
                .unwrap_or_else(|_| "postgres://localhost/mint_website_development".to_string()),
            github_client_id: env::var("GITHUB_KEY")
                .expect("GITHUB_KEY must be set"),
            github_client_secret: env::var("GITHUB_SECRET")
                .expect("GITHUB_SECRET must be set"),
            sandbox_url: env::var("SANDBOX_URL")
                .unwrap_or_else(|_| "http://localhost:3000".to_string()),
            host: env::var("HOST")
                .unwrap_or_else(|_| "127.0.0.1".to_string()),
            port: env::var("PORT")
                .unwrap_or_else(|_| "8080".to_string())
                .parse()
                .expect("PORT must be a valid number"),
        })
    }

    pub fn server_addr(&self) -> String {
        format!("{}:{}", self.host, self.port)
    }

    pub fn callback_url(&self) -> String {
        format!("http://{}:{}/auth/github/callback", self.host, self.port)
    }
}
