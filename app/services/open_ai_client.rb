require 'openai'

class OpenAiClient
  def initialize
    @client = OpenAI::Client.new
  end

  def chat(message, chat_mode)
    @client.responses.create(
      parameters: {
        model: chat_mode,
        input: message,
        reasoning: { effort: 'minimal' }
      }
    ).dig('output', 1, 'content', 0, 'text')
  end
end
