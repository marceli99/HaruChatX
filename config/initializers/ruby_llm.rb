# frozen_string_literal: true

RubyLLM.configure do |config|
  config.openai_api_key = Rails.application.credentials.dig(:openai, :access_key)
  config.anthropic_api_key = Rails.application.credentials.dig(:anthropic, :access_key)
  config.gemini_api_key = Rails.application.credentials.dig(:gemini, :access_key)
  config.vertexai_project_id = Rails.application.credentials.dig(:google_cloud, :project_id)
  config.vertexai_location = Rails.application.credentials.dig(:google_cloud, :location)
  config.deepseek_api_key = Rails.application.credentials.dig(:deepseek, :access_key)
  config.mistral_api_key = Rails.application.credentials.dig(:mistral, :access_key)
  config.perplexity_api_key = Rails.application.credentials.dig(:perplexity, :access_key)
  config.openrouter_api_key = Rails.application.credentials.dig(:openrouter, :access_key)

  config.use_new_acts_as = true
end
