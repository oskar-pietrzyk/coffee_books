class CreateRentals < ActiveRecord::Migration[8.1]
  def change
    create_table :rentals do |t|
      t.date :duration_date, null: false
      t.datetime :borrowed_at, null: false
      t.datetime :returned_at
      t.string :reading_status, null: false, default: "borrowed"
      t.references :book, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: { to_table: :readers }
      t.datetime :reminder_sent_at
      t.datetime :due_reminder_sent_at
      t.timestamps
    end

    add_index :rentals, [:reading_status, :duration_date]
    add_index :rentals, [:book_id, :reading_status]
    add_index :rentals, [:user_id, :reading_status]
    add_index :rentals, :book_id,
      unique: true,
      where: "reading_status = 'borrowed'",
      name: "index_rentals_on_book_id_active"
  end
end