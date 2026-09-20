class AddBooksCreatedAtIndex < ActiveRecord::Migration[8.1]
  def change
    add_index :books, [:created_at, :id], order: { created_at: :desc, id: :desc }
  end
end