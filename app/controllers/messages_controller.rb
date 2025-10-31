# frozen_string_literal: true

class MessagesController < ApplicationController
  def create # rubocop:disable Metrics/MethodLength
    return redirect_back(fallback_location: root_path) if params[:message].blank?

    chat_mode = params[:chat_mode]
    @message_content = params[:message]
    @stream_id = SecureRandom.uuid

    GenerateResponseJob.perform_later(
      conversation_id: conversation.id,
      input: @message_content,
      model: chat_mode,
      stream_id: @stream_id
    )

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def conversation
    @conversation ||= if params[:conversation_id].present?
                        Conversation.find(params[:conversation_id])
                      else
                        Conversation.create!(user: Current.user, title: 'New Conversation')
                      end
  end

  def message_params
    params.expect(message: [:content])
  end
end
