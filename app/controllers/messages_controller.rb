# frozen_string_literal: true

class MessagesController < ApplicationController
  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    return redirect_back(fallback_location: root_path) if params[:message].blank?

    chat_mode = params[:chat_mode]
    message_content = params[:message]
    response_identifier = conversation.messages.last&.previous_response_identifier

    @user_message = conversation.messages.create!(
      role: :user,
      status: :completed,
      content: message_content,
      model: chat_mode,
      previous_response_identifier: response_identifier
    )

    if conversation.messages.one?
      # TODO: Move title creation to a job to avoid slowing down response
      conversation.update!(title: 'Temporary title')
    end

    @assistant_message = conversation.messages.create!(
      role: :assistant,
      status: :generating,
      content: '',
      model: chat_mode
    )

    GenerateResponseJob.perform_later(
      message_id: @assistant_message.id,
      input: message_content,
      model: chat_mode,
      previous_response_id: response_identifier
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
                        Conversation.create!(user: Current.user)
                      end
  end

  def message_params
    params.expect(message: [:content])
  end
end
