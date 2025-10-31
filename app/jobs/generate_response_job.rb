# frozen_string_literal: true

class GenerateResponseJob < ApplicationJob
  queue_as :default

  def perform(message_id:, input:, model:, previous_response_id: nil)
    @message_id = message_id
    @model = model
    @input = input
    @previous_response_id = previous_response_id

    run
  end

  private

  attr_reader :message_id, :input, :model, :previous_response_id

  def run # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    buffer = +''

    Clients::ChatGpt.new(model: @model).chat_stream(
      input: input,
      previous_response_id: previous_response_id
    ) do |chunk|
      case chunk[:type]
      when :delta
        delta = chunk[:content]
        buffer << delta
        ActionCable.server.broadcast("message_#{message.id}", { type: 'delta', text: delta })
      when :response_created
        message.update!(previous_response_identifier: chunk[:response_id])
      end
    end
    message.update!(content: buffer, status: :completed)
  rescue StandardError => e
    message.update!(content: buffer, status: :failed)
    ActionCable.server.broadcast("message_#{message.id}", { type: 'delta', text: "\n\n[Stream error]" })
    Rails.logger.error("GenerateResponseJob failed for Message ID #{message_id}: #{e.message}")
  end

  def message
    @message ||= Message.find(message_id)
  end
end
