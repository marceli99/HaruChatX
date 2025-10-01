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
        instructions: 'Jesteś miłym asystentem AI, odpowiadaj na pytanie w języku pytania. Jeśli nie znasz odpowiedzi, nie zmyślaj jej. Odpowiadaj krótko i na temat. Jeśli twoja odpowiedź zawiera kod programistyczny, umieść go w znaczniku <pre><code></code></pre>.',
        reasoning: { effort: 'minimal' }
      }
    ).dig('output', 1, 'content', 0, 'text')
  end
end
