require "rails_helper"

RSpec.describe BorrowBook do
  it "creates an active rental and marks the book borrowed" do
    book = Book.create!(title: "Dune", author: "Frank Herbert")
    reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")

    rental = described_class.call(book: book, borrowed_at: Time.current, reader_uuid: reader.uuid)

    expect(rental).to be_borrowed
    expect(rental.reader).to eq(reader)
    expect(book.reload).to be_borrowed
  end
end