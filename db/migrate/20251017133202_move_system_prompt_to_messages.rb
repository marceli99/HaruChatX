class MoveSystemPromptToMessages < ActiveRecord::Migration[8.0]
  def change
    remove_column :conversations, :system_prompt, :text
    add_column :messages, :system_prompt, :text
  end
end
