# frozen_string_literal: true

class Clients::ChatGpt
  module Effort
    MINIMAL = 'minimal'
    LOW = 'low'
    MEDIUM = 'medium'
    HIGH = 'high'
  end

  module Verbosity
    LOW = 'low'
    MEDIUM = 'medium'
    HIGH = 'high'
  end

  DEFAULT_SYSTEM_PROMPT = 'Jesteś miłym asystentem AI, odpowiadaj w języku pytania. Jeśli nie wiesz – nie zmyślaj.
  Krótko. Kod w <pre><code>...</code></pre>.'

  DELTA_CHUNK_TYPE = 'response.output_text.delta'
  RESPONSE_CREATED_TYPE = 'response.created'

  def initialize(model: 'gpt-5', effort: Effort::MEDIUM, verbosity: Verbosity::MEDIUM)
    @model = model
    @effort = effort
    @verbosity = verbosity
  end

  def chat(input:, previous_response_id: nil)
    response = fetch_response(input, previous_response_id)

    {
      text: parse_response(response),
      response_id: response['id']
    }
  end

  def chat_stream(input:, previous_response_id: nil)
    fetch_response(input, previous_response_id) do |chunk, _event|
      parsed_chunk = parse_stream_chunk(chunk)

      yield parsed_chunk if parsed_chunk
    end
  end

  private

  attr_reader :model, :effort, :verbosity

  def parse_stream_chunk(chunk)
    case chunk['type']
    when DELTA_CHUNK_TYPE
      { type: :delta, content: chunk['delta'] }
    when RESPONSE_CREATED_TYPE
      { type: :response_created, response_id: chunk.dig('response', 'id') }
    end
  end

  def parse_response(response)
    response.dig('output', 1, 'content', 0, 'text')
  end

  def fetch_response(input, previous_response_id, &)
    internal_client.responses.create(parameters: build_parameters(input, previous_response_id, &))
  end

  def build_parameters(input, previous_response_id, &block)
    {
      model: model,
      instructions: DEFAULT_SYSTEM_PROMPT,
      input: input,
      reasoning: { effort: effort },
      text: { verbosity: verbosity },
      store: true,
      previous_response_id: previous_response_id
    }.tap { |params| params[:stream] = block if block }
  end

  def internal_client
    @internal_client ||= OpenAI::Client.new
  end
end
