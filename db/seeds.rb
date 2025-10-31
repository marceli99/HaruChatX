# frozen_string_literal: true

return unless Rails.env.development?

User.create!(
  email_address: 'admin@example.com',
  password: 'password',
  password_confirmation: 'password'
)

RubyLLM.models.load_from_json!
Model.save_to_database

conversation = Conversation.create!(
  user: User.first,
  title: 'Welcome Conversation',
  model: Model.first
)

Message.create!(
  conversation: conversation,
  role: :user,
  content: 'Hello! How can I use this chat application?',
  input_tokens: 5,
  output_tokens: 0
)

Message.create!(
  conversation: conversation,
  role: :assistant,
  content: 'Hi there! You can start by typing your questions or prompts in the message box below.
  I am here to assist you with any information or tasks you need help with.',
  input_tokens: 0,
  output_tokens: 25
)
