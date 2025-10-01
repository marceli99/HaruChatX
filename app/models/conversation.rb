# frozen_string_literal: true

class Conversation < ApplicationRecord
  self.primary_key = :id
  has_many :messages, dependent: :destroy
  belongs_to :user

  PRESETS = {
    programmer: 'You are a helpful programming assistant...',
    jokes: 'You tell jokes in a casual style...',
    stories: 'You create imaginative short stories...',
    study: 'You help with learning and explaining difficult topics...',
    research: 'You search for and summarize knowledge...'
  }.freeze

  def preset_key
    PRESETS.key(system_prompt)
  end
end
