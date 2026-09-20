class AddArchivedToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :archived, :boolean, null: false, default: false
    add_index :books, :archived
  end
end