class ChangeConversationsIdToUuid < ActiveRecord::Migration[6.0]
  def up
    add_column :conversations, :uuid, :uuid, default: "gen_random_uuid()", null: false

    if column_exists?(:messages, :conversation_id)
        # Remove foreign key constraint
        remove_foreign_key :messages, :conversations
        add_column :messages, :conversation_uuid, :uuid
      execute <<-SQL.squish
        UPDATE messages SET conversation_uuid = conversations.uuid
        FROM conversations WHERE messages.conversation_id = conversations.id
      SQL
    end

      remove_column :conversations, :id, force: :cascade
    rename_column :conversations, :uuid, :id
    execute "ALTER TABLE conversations ADD PRIMARY KEY (id);"

    if column_exists?(:messages, :conversation_id)
      remove_column :messages, :conversation_id
      rename_column :messages, :conversation_uuid, :conversation_id
        add_foreign_key :messages, :conversations, column: :conversation_id, primary_key: :id
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
