# frozen_string_literal: true

class MessageChannel < ApplicationCable::Channel
  def subscribed
    reject if params[:id].blank?

    stream_from "message_#{params[:id]}"
  end
end
