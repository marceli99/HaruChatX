class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true, index: true

      t.integer :role, null: false

      t.text :content, null: false
      t.string :model, null: false

      t.timestamps
    end

    add_index :messages, [:conversation_id, :created_at]
  end
end
