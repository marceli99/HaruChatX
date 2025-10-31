# frozen_string_literal: true

class Message < ApplicationRecord
  enum :role, { user: 0, assistant: 1, system: 2 }
  enum :status, { generating: 0, completed: 1, failed: 2 }

  belongs_to :conversation, primary_key: :id, inverse_of: :messages
end
