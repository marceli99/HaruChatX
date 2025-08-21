require 'openai'

class OpenAiClient

  def initialize
    @client = OpenAI::Client.new
  end

  def chat(message)
    @client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [{ role: "user", content: message}],
        temperature: 0.7,
        stream: proc do |chunk, _event|
          print chunk.dig("choices", 0, "delta", "content")
        end
      }
    )
  end
end