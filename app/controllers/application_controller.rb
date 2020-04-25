class ApplicationController < ActionController::Base
  before_action :set_vary

  def set_vary
    response.set_header('Vary', 'X-Requested-With')
  end
end
