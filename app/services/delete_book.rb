class DeleteBook < ApplicationService
  attr_reader :uuid

  def initialize(uuid:)
    @uuid = uuid
  end

  def call
    book = Book.find_by!(uuid: uuid)
    rental = book.rentals.active.includes(:reader).first

    if book.borrowed?
      raise BookBorrowedError.new(
        book: book,
        rental: rental,
        serialized_book: BookSerializer.serialize(book)
      )
    end

    book.update!(archived: true)
    serialized_book = BookSerializer.serialize(book)

    {
      message: 'Book archived',
      book: serialized_book
    }
  end
end