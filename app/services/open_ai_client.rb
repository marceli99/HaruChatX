# frozen_string_literal: true

require 'openai'

class OpenAiClient
  DEFAULT_SYSTEM = 'Jesteś miłym asystentem AI, odpowiadaj w języku pytania. Jeśli nie wiesz, nie zmyślaj. ' \
                   'Odpowiadaj zwięźle i na temat. Kod pisz w <pre><code>...</code></pre>'

  def initialize(client: OpenAI::Client.new)
    @client = client
  end

  def chat(message, chat_mode, system_prompt: nil)
    buffer = +''
    response_id = nil
    usage = nil

    stream_proc = proc do |chunk, _event|
      case chunk['type']
      when 'response.output_text.delta'
        buffer << chunk['delta'].to_s
      when 'response.created', 'response.completed'
        response_id ||= chunk.dig('response', 'id') || chunk['id']
        usage ||= chunk.dig('response', 'usage') || chunk['usage']
      when 'response.error'
        raise(chunk.dig('error', 'message') || 'OpenAI streaming error')
      end
    end

    @client.responses.create(
      parameters: {
        model: chat_mode,
        input: message,
        instructions: system_prompt || DEFAULT_SYSTEM,
        reasoning: { effort: 'minimal' },
        stream: stream_proc
      }
    )

    if usage.nil? && response_id
      begin
        final = @client.responses.retrieve(response_id: response_id)
        usage = final['usage']
      rescue Faraday::ClientError
      end
    end

    buffer
  rescue Faraday::ClientError => e
    body = e.response&.dig(:body)
    raise "OpenAI API error #{e.message}#{" | #{body}" if body}"
  end
end
