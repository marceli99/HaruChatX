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

  def initialize(model: 'gpt-5', effort: Effort::MINIMAL, verbosity: Verbosity::LOW)
    @model = model
    @effort = effort
    @verbosity = verbosity
  end

  def chat(input:)
    parse_response(fetch_response(input))
  end

  def chat_stream(input:)
    fetch_response(input) do |chunk, _event|
      yield chunk['delta'] if delta_chunk(chunk)
    end
  end

  private

  def delta_chunk?(chunk)
    chunk['type'] == DELTA_CHUNK_TYPE
  end

  def parse_response(response)
    JSON.parse(response.dig('output', 1, 'content', 0, 'text'))
  end

  def fetch_response(input, &)
    internal_client.responses.create(parameters: build_parameters(input, &))
  end

  def build_parameters(input, &block)
    {
      model: model,
      instructions: DEFAULT_SYSTEM_PROMPT,
      input: input,
      reasoning: { effort: effort },
      text: { verbosity: verbosity }
    }.tap { |params| params[:stream] = block if block }
  end

  def internal_client
    @internal_client ||= OpenAiClient.new
  end

  attr_reader :model, :effort, :verbosity
end
