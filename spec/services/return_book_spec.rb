require "rails_helper"

RSpec.describe ReturnBook do
  it "closes the active rental and marks the book available" do
    book = Book.create!(title: "Dune", author: "Frank Herbert")
    reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")
    rental = Rental.create!(book: book, reader: reader)
    book.update!(availability_status: :borrowed)

    returned_rental = described_class.call(book: book)

    expect(returned_rental).to be_returned
    expect(returned_rental.returned_at).to be_present
    expect(book.reload).to be_available
  end
end