class ChangeMessages < ActiveRecord::Migration[8.0]
  def change
    drop_table :messages, if_exists: true do |t|
      t.integer :role, null: false
      t.text :content, null: false
      t.string :model, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.uuid :conversation_id
      t.string :previous_response_identifier
      t.text :system_prompt
      t.string :status, default: "generating", null: false
    end

    create_table :messages do |t|
      t.string :role, null: false
      t.text :content
      t.integer :input_tokens
      t.integer :output_tokens
      t.timestamps
    end

    add_index :messages, :role
  end
end
