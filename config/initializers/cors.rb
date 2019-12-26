Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000', 'sandbox.mint-lang.com'

    resource '*',
    	credentials: true,
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
