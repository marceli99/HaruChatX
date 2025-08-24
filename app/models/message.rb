class Message < ApplicationRecord
  enum :role, { user: 0, assistant: 1, system: 2 }

  belongs_to :conversation
end
