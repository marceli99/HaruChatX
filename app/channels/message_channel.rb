# frozen_string_literal: true

class MessageChannel < ApplicationCable::Channel
  def subscribed
    puts "Subscribing to MessageChannel with ID: #{params[:id]}"
    reject if params[:id].blank?
    stream_from "message_#{params[:id]}"
    puts "Successfully subscribed to message_#{params[:id]}"
  end

  def unsubscribed
    puts "Unsubscribed from MessageChannel with ID: #{params[:id]}"
  end
end
