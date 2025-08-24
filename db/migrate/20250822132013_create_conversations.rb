class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :title
      t.text :system_prompt

      t.timestamps
    end

    add_index :conversations, [:user_id, :updated_at]
  end
end
