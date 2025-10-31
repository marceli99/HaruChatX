# frozen_string_literal: true

class GenerateResponseJob < ApplicationJob
  queue_as :default

  DEFAULT_SYSTEM_PROMPT = 'Jesteś miłym asystentem AI, odpowiadaj w języku pytania. Jeśli nie wiesz – nie zmyślaj.
  Krótko. Kod w <pre><code>...</code></pre>.'

  def perform(conversation_id:, input:, model:, stream_id:)
    @conversation_id = conversation_id
    @model = model
    @input = input
    @stream_id = stream_id

    run
  end

  private

  attr_reader :conversation_id, :input, :model, :stream_id

  def run
    conversation.with_model(model).with_instructions(DEFAULT_SYSTEM_PROMPT).ask(input) do |chunk|
      Rails.logger.info("Streaming chunk: #{chunk.inspect}")
      if chunk.content.present?
        ActionCable.server.broadcast("message_#{stream_id}", { type: 'chunk', content: chunk.content })
      end
    end
  rescue StandardError => e
    handle_error(e)
  end

  def handle_error(error)
    sleep 1 # Wait a second for the client channel to be ready
    Rails.logger.error("Error generating response: #{error.message}")

    if Rails.env.development?
      ActionCable.server.broadcast("message_#{stream_id}", { type: 'error', message: error.message })
    else
      ActionCable.server.broadcast("message_#{stream_id}",
                                   { type: 'error', message: 'An error occurred while generating the response.' })
    end
  end

  def conversation
    Conversation.find(conversation_id)
  end
end
