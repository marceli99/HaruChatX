# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :require_authentication

  def create
    @conversation = Conversation.find(params[:conversation_id])

    return if params[:message].blank?

    @chat_mode = params[:chat_mode]
    @message_content = params[:message]

    @user_message = @conversation.messages.create!(
      role: :user,
      content: @message_content,
      model: @chat_mode
    )

    if @conversation.messages.one?
      title_prompt = I18n.t('conversations.title_prompt', content: @message_content)
      new_title = OpenAiClient.new.chat(title_prompt, 'gpt-5-nano')
      @conversation.update!(title: new_title.strip)
    end

    reply_text = OpenAiClient.new.chat(@message_content, @chat_mode)

    @assistant_message = @conversation.messages.create!(
      role: :assistant,
      content: reply_text,
      model: @chat_mode
    )

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end

  private

  def message_params
    params.expect(message: [:content])
  end
end
