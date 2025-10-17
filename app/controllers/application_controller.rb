# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication

  allow_browser versions: :modern
  before_action :require_authentication
end
