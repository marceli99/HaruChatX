# frozen_string_literal: true

class ConversationsController < ApplicationController
  before_action :require_authentication

  def show
    @conversation = Conversation.find(params[:id])
    @conversation.update!(system_prompt: Conversation::PRESETS[params[:preset]]) if params[:preset].present?
    @messages = @conversation.messages.order(created_at: :asc)

    return if params[:message].blank?

    @chat_mode = params[:chat_mode]
    @message = params[:message]
    @reply = OpenAiClient.new.chat(@message, @chat_mode)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to root_path }
    end
  end

  def create
    conversation = Current.user.conversations.new(title: t('conversations.new_title'))
    conversation.save!
    redirect_to conversation_path(conversation)
  end

  def destroy
    @conversation = Current.user.conversations.find(params[:id])
    @conversation.destroy

    redirect_to root_path, notice: t('flash.conversations.destroyed')
  end

  private

  def conversation_params
    params.expect(conversation: %i[title system_prompt])
  end
end
