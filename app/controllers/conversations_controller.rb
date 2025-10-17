# frozen_string_literal: true

class ConversationsController < ApplicationController
  def show
    @conversation = Conversation.find(params[:id])
    @messages = @conversation&.messages&.order(created_at: :asc)
    @chat_mode = last_used_chat_mode
    @message = params[:message]

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def new
    @chat_mode = last_used_chat_mode
  end

  def destroy
    @conversation = Current.user.conversations.find(params[:id])
    @conversation.destroy

    redirect_to root_path, notice: t('flash.conversations.destroyed')
  end

  private

  def last_used_chat_mode
    Current.user.messages.last&.model
  end

  def conversation_params
    params.expect(conversation: %i[title system_prompt])
  end
end
