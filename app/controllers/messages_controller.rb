# frozen_string_literal: true

class MessagesController < ApplicationController
  def create
    @conversation = Conversation.find(params[:conversation_id])

    return if params[:message].blank?

    @chat_mode = params[:chat_mode]
    @message_content = params[:message]
    @response_identifier = @conversation.messages.last&.previous_response_identifier

    @user_message = @conversation.messages.create!(
      role: :user,
      content: @message_content,
      model: @chat_mode,
      previous_response_identifier: @response_identifier
    )

    if @conversation.messages.one?
      # TODO: Move title creation to a job to avoid slowing down response
      @conversation.update!(title: 'Temporary title')
    end

    reply_text = Clients::ChatGpt.new(model: @chat_mode).chat(input: @message_content)
    @assistant_message = @conversation.messages.create!(
      role: :assistant,
      content: reply_text,
      model: @chat_mode,
      previous_response_identifier: reply_text[:response_id]
    )

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end

  private

  def conversation
    @conversation ||= if params[:conversation_id].present?
                        Conversation.find(params[:conversation_id])
                      else
                        Conversation.new(system_prompt: Conversation::PRESETS[params[:preset]])
                      end
  end

  def message_params
    params.expect(message: [:content])
  end
end
