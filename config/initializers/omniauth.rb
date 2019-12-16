Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, '2815248f2f4e09a47972', 'f3081547414c59c55f433b1f35a33387a84241b6'
end

OmniAuth.config.logger = Rails.logger
