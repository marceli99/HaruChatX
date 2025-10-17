# frozen_string_literal: true

class MessagesController < ApplicationController
  def create
    return head :unprocessable_entity if params[:message].blank?

    chat_mode = params[:chat_mode]
    message_content = params[:message]
    existing_conversation = params[:conversation_id].present?
    response_identifier = conversation.messages.last&.previous_response_identifier

    @user_message = conversation.messages.create!(
      role: :user,
      content: message_content,
      model: chat_mode,
      previous_response_identifier: response_identifier
    )

    if conversation.messages.one?
      # TODO: Move title creation to a job to avoid slowing down response
      conversation.update!(title: 'Temporary title')
    end

    response ||= Clients::ChatGpt.new(model: chat_mode).chat(
      input: message_content,
      previous_response_id: response_identifier
    )

    @assistant_message = conversation.messages.create!(
      role: :assistant,
      content: response[:text],
      model: chat_mode,
      previous_response_identifier: response[:response_id]
    )

    respond_to do |format|
      if existing_conversation
        format.turbo_stream
      else
        format.html { redirect_to conversation_path(conversation) }
        format.turbo_stream { redirect_to conversation_path(conversation) }
      end
    end
  end

  private

  def conversation
    @conversation ||= if params[:conversation_id].present?
                        Conversation.find(params[:conversation_id])
                      else
                        Conversation.create!(user: Current.user)
                      end
  end

  def message_params
    params.expect(message: [:content])
  end
end
