# frozen_string_literal: true

class MessageChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.debug { "Subscribing to MessageChannel with ID: #{params[:id]}" }
    reject if params[:id].blank?
    stream_from "message_#{params[:id]}"
    Rails.logger.debug { "Successfully subscribed to message_#{params[:id]}" }
  end

  def unsubscribed
    Rails.logger.debug { "Unsubscribed from MessageChannel with ID: #{params[:id]}" }
  end
end
