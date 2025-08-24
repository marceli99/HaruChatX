# frozen_string_literal: true

require 'openai'

class OpenAiClient
  def initialize
    @client = OpenAI::Client.new
  end

  def chat(message, chat_mode, system_prompt: nil)
    @client.responses.create(
      parameters: {
        model: chat_mode,
        input: message,
        # system_prompt: system_prompt,
        reasoning: { effort: 'minimal' }
      }
    ).dig('output', 1, 'content', 0, 'text')
  end
end
