# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication

  allow_browser versions: :modern
  before_action :require_authentication

  def index
    conversation = Current.user.conversations.order(created_at: :desc).first

    conversation ||= Current.user.conversations.create!(title: 'New chat')
    redirect_to conversation_path(conversation)
  end
end
