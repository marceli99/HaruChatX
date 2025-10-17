class AddPreviousResponseIdentifierToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :previous_response_identifier, :string
    add_index :messages, :previous_response_identifier
  end
end
