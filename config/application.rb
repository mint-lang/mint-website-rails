require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_text/engine"
require "sprockets/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MintWebsiteBackend
  class Application < Rails::Application
    config.load_defaults 6.0
    config.autoload_paths += Dir.glob("#{config.root}/app/interactions/*")
  end
end

Rails.autoloaders.main.ignore(Rails.root.join('app/guides'))
