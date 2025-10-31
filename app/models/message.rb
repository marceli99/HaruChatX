# frozen_string_literal: true

class Message < ApplicationRecord
  acts_as_message chat: :conversation

  has_many_attached :attachments

  validates :role, presence: true
end
