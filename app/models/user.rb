# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :messages, through: :conversations

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
