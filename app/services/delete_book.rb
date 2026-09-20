class DeleteBook < ApplicationService
  attr_reader :uuid

  def initialize(uuid:)
    @uuid = uuid
  end

  def call
    book = Book.find_by!(uuid: uuid)
    rental = book.rentals.active.includes(:reader).first
    serialized_book = BookSerializer.serialize(book)

    if book.borrowed?
      raise BookBorrowedError.new(book: book, rental: rental, serialized_book: serialized_book)
    end

    if book.rentals.exists?
      raise BookHasRentalHistoryError.new(book: book, serialized_book: serialized_book)
    end

    book.destroy!

    {
      message: 'Book deleted',
      book: serialized_book
    }
  end
end