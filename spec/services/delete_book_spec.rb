require "rails_helper"

RSpec.describe DeleteBook do
  let(:book) { Book.create!(title: "Dune", author: "Frank Herbert") }

  it "deletes an available book" do
    book_uuid = book.uuid

    deleted_book = described_class.call(uuid: book_uuid)

    expect(Book.find_by(uuid: book_uuid)).to be_nil
    expect(deleted_book).to include(
      message: 'Book deleted',
      book: include(uuid: book_uuid, title: 'Dune', author: 'Frank Herbert')
    )
  end

  it "deletes only the book identified by uuid when title and author are duplicated" do
    duplicate = Book.create!(title: book.title, author: book.author)

    described_class.call(uuid: book.uuid)

    expect(Book.find_by(id: book.id)).to be_nil
    expect(Book.find_by(id: duplicate.id)).to be_present
  end

  it "raises with the active rental when the book is borrowed" do
    reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")
    rental = Rental.create!(book: book, reader: reader)
    book.update!(availability_status: :borrowed)

    error = catch_error { described_class.call(uuid: book.uuid) }

    expect(error).to be_a(BookBorrowedError)
    expect(error.book).to eq(book)
    expect(error.rental).to eq(rental)
    expect(error.rental.reader).to eq(reader)
    expect(error.serialized_book).to include(
      uuid: book.uuid,
      rentals: include(
        include(
          reading_status: 'borrowed',
          reader: include(uuid: reader.uuid, full_name: reader.full_name)
        )
      )
    )
  end

  it "raises RecordNotFound for an unknown uuid" do
    expect {
      described_class.call(uuid: "999999")
    }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "preserves returned rental history" do
    reader = Reader.create!(full_name: "Ada Lovelace", email: "ada@example.com")
    rental = Rental.create!(book: book, reader: reader)
    rental.return!

    error = catch_error { described_class.call(uuid: book.uuid) }

    expect(error).to be_a(BookHasRentalHistoryError)
    expect(Book.find_by(id: book.id)).to be_present
    expect(Rental.find_by(id: rental.id)).to be_present
  end

  private

  def catch_error
    yield
  rescue StandardError => error
    error
  end
end