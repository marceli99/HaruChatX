# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication

  allow_browser versions: :modern
  before_action :require_authentication

  def index; end

  def create
    return if params[:message].blank?

    @chat_mode = params[:chat_mode]
    @message = params[:message]
    @reply = OpenAiClient.new.chat(@message, @chat_mode)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end
end
