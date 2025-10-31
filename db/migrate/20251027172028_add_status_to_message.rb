class AddStatusToMessage < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :status, :string, default: 'generating', null: false
  end
end
