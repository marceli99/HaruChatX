class AddReferencesToChatsToolCallsAndMessages < ActiveRecord::Migration[8.0]
  def change
    add_reference :conversations, :model, foreign_key: true
    add_reference :tool_calls, :message, null: false, foreign_key: true
    add_reference :messages, :conversation, null: false, foreign_key: true, type: :uuid
    add_reference :messages, :model, foreign_key: true
    add_reference :messages, :tool_call, foreign_key: true
  end
end
