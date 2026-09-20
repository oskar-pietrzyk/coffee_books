class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :uuid, null: false, limit: 6
      t.string :title, null: false
      t.string :author, null: false
      t.string :availability_status, null: false, default: "available"
      t.timestamps
    end

    add_index :books, :uuid, unique: true
    add_index :books, :availability_status
  end
end